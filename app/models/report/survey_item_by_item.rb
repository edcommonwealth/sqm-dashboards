module Report
  class SurveyItemByItem
    def self.create_item_report(schools:, academic_years:, filename:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      csv = to_csv(schools:, academic_years:, use_student_survey_items:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(csv:, filepath:)
      csv
    end

    def self.to_csv(schools:, academic_years:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      # first, determine headers by finding the school and grades
      # Q: Should a grade not be included if it has no sufficient responses?
      # A: Include all grades, except preschool

      # Convert they keys in this hash to a hash where the key is the grade
      # and the value is a set of sufficient survey IDs
      survey_ids_to_grades = {}

      sufficient_responses_by_grade_and_survey_item_id = ::SurveyItemResponse.where(school: schools, academic_year: academic_years, survey_item_id: use_student_survey_items).where.not(grade: nil).having("count(*) >= ?", 10).group(
        :grade, :survey_item_id
      ).count

      sufficient_responses_by_grade_and_survey_item_id.each do |key, count|
        # key[1] is survey item ID
        # key[0] is grade
        survey_ids_to_grades[key[1]] ||= Set.new
        # we do not display the grade avg if there are < 10 responses
        survey_ids_to_grades[key[1]].add(key[0]) if count >= 10
      end

      grades = Respondent.grades_that_responded_to_survey(academic_year: academic_years, school: schools)
      # Then, add the headers to data
      data = []
      data << generate_headers(schools:, academic_years:, grades:)

      survey_items_by_id = ::SurveyItem.by_id_includes_all

      # mutex = Thread::Mutex.new
      # pool_size = 2
      # jobs = Queue.new
      # schools.each { |school| jobs << school }

      academic_years.each do |academic_year|
        next unless ::SurveyItemResponse.where(school: schools, academic_year: academic_year, survey_item_id: use_student_survey_items).count > 100

        schools.each do |school|
          # for each survey item id
          survey_ids_to_grades.sort_by do |id, _value|
            survey_items_by_id[id].prompt
          end.each do |id, school_grades|
            school_grades = school_grades.reject(&:nil?)
            row = []
            survey_item = survey_items_by_id[id]
            row.concat(survey_item_info(survey_item:)) # fills prompt + categories
            row.append("Students")
            row.append(school.name)
            row.append(academic_year.range)

            # add padding before grade average section
            starting_grade = school_grades.sort.first
            starting_grade = grades.index(starting_grade) || 0
            padding = Array.new(starting_grade) { "" }
            row.concat(padding)

            school_grades.sort.each do |grade|
              next if grade == -1

              if school_grades.include?(grade)
                # we already know grade has sufficient responses
                score = survey_item.survey_item_responses.where(school:, academic_year:,
                                                                grade:).average(:likert_score).to_f.round(2)
                score = "" if score.zero?
                row.append("#{score}")
              else
                row.append("")
              end
            end

            # add padding after the grade average section
            ending_grade = school_grades.sort.last
            ending_grade = grades.index(ending_grade) + 1 || 0
            padding = Array.new(grades.length - ending_grade) { "" }
            row.concat(padding)

            # filter out response rate at subcategory level <24.5% for school average
            if response_rate(subcategory: survey_item.subcategory, school:,
                             academic_year:).meets_student_threshold?
              all_student_score = survey_item.survey_item_responses.where(
                # We allow the nil (unknown) grades in the school survey item average
                # also filter less than 10 responses in the whole school
                "school_id = ? and academic_year_id = ? and (grade IS NULL or grade IN (?))", school.id, academic_year.id, school.grades(academic_year:)
              ).group("survey_item_id").having("count(*) >= 10").average(:likert_score).values[0].to_f.round(2)

              all_student_score = "" if all_student_score.zero?
              row.append("#{all_student_score}")
            else
              row.append("")
            end
            data << row
          end
          # Next up is teacher data
          # each key is a survey item id
          ::SurveyItemResponse.teacher_survey_items_with_sufficient_responses(school:,
                                                                              academic_year:).keys.sort_by do |id|
            survey_items_by_id[id].prompt
          end.each do |key|
            row = []
            survey_item = survey_items_by_id[key]
            row.concat(survey_item_info(survey_item:))
            row.append("Teacher")
            row.append(school.name)
            row.append(academic_year.range)
            # we need to add padding to skip the grades columns and the 'all school' column
            padding = Array.new(grades.length + 1) { "" }
            row.concat(padding)
            # we already know that the survey item we are looking at has sufficient responses
            all_teacher_score = survey_item.survey_item_responses.where(school:,
                                                                        academic_year:).average(:likert_score).to_f.round(2)
            all_teacher_score = "" if all_teacher_score.zero?
            row.append("#{all_teacher_score}")
            data << row
          end
        end
      end

      CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
    end

    def self.response_rate(subcategory:, school:, academic_year:)
      @response_rate ||= Hash.new do |memo, (subcategory, school, academic_year)|
        memo[[subcategory, school, academic_year]] =
          ::StudentResponseRateCalculator.new(subcategory:, school:, academic_year:)
      end

      @response_rate[[subcategory, school, academic_year]]
    end

    def self.write_csv(csv:, filepath:)
      File.write(filepath, csv)
    end

    def self.survey_item_info(survey_item:)
      [survey_item.prompt,
       survey_item.category.name,
       survey_item.subcategory.name,
       survey_item.measure.name,
       survey_item.scale.scale_id]
    end

    def self.generate_headers(schools:, academic_years:, grades:)
      headers = [
        "Survey Item",
        "Category",
        "Subcategory",
        "Survey Measure",
        "Survey Scale",
        "Survey Population",
        "School Name",
        "Academic Year"
      ]

      grades.each do |value|
        if value == 0
          headers.append("Kindergarten")
        else
          headers.append("Grade #{value}")
        end
      end
      headers.append("All School")
      headers.append("Teacher")
      headers
    end
  end
end
