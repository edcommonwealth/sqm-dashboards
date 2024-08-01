module Report
  class SurveyItemByItem
    def self.create_item_report(schools:, academic_years:, filename:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      data = to_csv(schools:, academic_years:, use_student_survey_items:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.to_csv(schools:, academic_years:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      # first, determine headers by finding the school and grades
      # Q: Should a grade not be included if it has no sufficient responses?
      # A: Include all grades, except preschool

      # Convert they keys in this hash to a hash where the key is the grade
      # and the value is a set of sufficient survey IDs
      survey_ids_to_grades = {}
      ::SurveyItemResponse.student_survey_items_with_responses_by_grade(
        school: schools,
        academic_year: academic_years
      ).select do |key, _value|
        use_student_survey_items.include?(key[1])
      end.each do |key, count|
        # key[1] is survey item ID
        # key[0] is grade
        survey_ids_to_grades[key[1]] ||= Set.new
        # we do not display the grade avg if there are < 10 responses
        survey_ids_to_grades[key[1]].add(key[0]) if count >= 10
      end
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

      grades = ::SurveyItemResponse.where(school: schools,
                                          academic_year: academic_years)
                                   .where.not(grade: nil)
                                   .pluck(:grade)
                                   .reject { |grade| grade == -1 } # ignore preschool
                                   .uniq
                                   .sort
      grades.each do |value|
        if value == 0
          headers.append("Kindergarten")
        else
          headers.append("Grade #{value}")
        end
      end
      headers.append("All School")
      headers.append("Teacher")
      # Then, add the headers to data
      data = []
      data << headers

      academic_years.each do |academic_year|
        schools.each do |school|
          # for each survey item id
          survey_ids_to_grades.each do |id, school_grades|
            row = []
            survey_item = survey_item_for_id(id)
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
                row.append("#{survey_item.survey_item_responses.where(school:, academic_year:,
                                                                      grade:).average(:likert_score).to_f.round(2)}")
              else
                row.append("N/A")
              end
            end

            # add padding after the grade average section
            ending_grade = school_grades.sort.last
            ending_grade = grades.index(ending_grade) + 1 || 0
            padding = Array.new(grades.length - ending_grade) { "" }
            row.concat(padding)

            # filter out response rate at subcategory level <24.5% for school average
            subcategory = scale_for_id(survey_item.scale_id).measure.subcategory
            # measure = ::Measure.find_by_id(scale.measure_id)
            # subcategory = ::Subcategory.find_by_id(measure.subcategory_id)
            if response_rate(subcategory:, school:, academic_year:).meets_student_threshold?
              row.append("#{survey_item.survey_item_responses.where(
                # We allow the nil (unknown) grades in the school survey item average
                # also filter less than 10 responses in the whole school
                'school_id = ? and academic_year_id = ? and (grade IS NULL or grade IN (?))', school.id, academic_year.id, school.grades(academic_year:)
              ).group('survey_item_id').having('count(*) >= 10').average(:likert_score).values[0].to_f.round(2)}")

            else
              row.append("N/A")
            end
            data << row
          end
          # Next up is teacher data
          ::SurveyItemResponse.teacher_survey_items_with_sufficient_responses(school:, academic_year:).keys.each do |key| # each key is a survey item id
            row = []
            survey_item = survey_item_for_id(key)
            row.concat(survey_item_info(survey_item:))
            row.append("Teacher")
            row.append(school.name)
            row.append(academic_year.range)
            # we need to add padding to skip the grades columns and the 'all school' column
            padding = Array.new(grades.length + 1) { "" }
            row.concat(padding)
            # we already know that the survey item we are looking at has sufficient responses
            row.append("#{survey_item.survey_item_responses.where(school:,
                                                                  academic_year:).average(:likert_score).to_f.round(2)}")
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
      @response_rate ||= Hash.new do |memo, subcategory, school, academic_year|
        memo[[subcategory, school, academic_year]] =
          ::StudentResponseRateCalculator.new(subcategory:, school:, academic_year:)
      end
      @response_rate[[subcategory, school, academic_year]]
    end

    def self.survey_item_for_id(survey_item_id)
      @survey_items ||= ::SurveyItem.all.map do |survey_item|
        [survey_item.id, survey_item]
      end.to_h
      @survey_items[survey_item_id]
    end

    def self.scale_for_id(scale_id)
      @scales ||= Scale.includes([measure: :subcategory]).all.map { |scale| [scale.id, scale] }.to_h
      @scales[scale_id]
    end

    def self.write_csv(data:, filepath:)
      File.write(filepath, csv)
    end

    def self.survey_item_info(survey_item:)
      prompt = survey_item.prompt
      scale = Scale.find_by_id(survey_item.scale_id)
      measure = ::Measure.find_by_id(scale.measure_id)
      subcategory = ::Subcategory.find_by_id(measure.subcategory_id)
      category = Category.find_by_id(subcategory.category_id)
      [prompt, category.name, subcategory.name, measure.name, scale.scale_id]
    end
  end
end
