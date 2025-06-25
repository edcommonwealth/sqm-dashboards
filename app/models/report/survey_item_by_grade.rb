module Report
  class SurveyItemByGrade
    def self.create_grade_report(schools:, academic_years:, filename:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      csv = to_csv(schools:, academic_years:, use_student_survey_items:)
      # write out file
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(csv:, filepath:)
      csv
    end

    def self.to_csv(schools:, academic_years:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      # get list of survey items with sufficient responses
      survey_items = Set.new
      # also get a map of grade->survey_id
      sufficient_survey_items = {}
      survey_items_by_id = ::SurveyItem.by_id_includes_all

      grades = Respondent.grades_that_responded_to_survey(academic_year: academic_years, school: schools)

      grades.each do |grade|
        sufficient_survey_items[grade] ||= Set.new
      end

      sufficient_responses_by_grade_and_survey_item_id = ::SurveyItemResponse.where(school: schools, academic_year: academic_years, survey_item_id: use_student_survey_items).where.not(grade: nil).having("count(*) >= ?", 10).group(
        :grade, :survey_item_id
      ).count

      sufficient_responses_by_grade_and_survey_item_id.each do |key, count|
        # key[1] is survey item id
        # key[0] is grade
        next if key[0].nil?

        survey_items.add(key[1])
        # we do not display the grade avg if there are < 10 responses
        sufficient_survey_items[key[0]].add(key[1]) if count >= 10
      end

      # write headers
      headers = [
        "School Name",
        "Grade",
        "Academic Year"
      ]
      survey_items = survey_items.sort_by { |id| survey_items_by_id[id].prompt }
      survey_items.each do |survey_item_id|
        headers << survey_items_by_id[survey_item_id].prompt
      end
      data = []
      data << headers

      academic_years.each do |academic_year|
        schools.each do |school|
          # for each grade, iterate through all survey items in our list
          # if it has sufficient responses, write out the avg score
          # else, write 'N/A'
          grades.each do |grade|
            next if grade == -1 # skip pre-k

            row = []
            row << school.name
            if grade == 0
              row.append("Kindergarten")
            else
              row.append("Grade #{grade}")
            end
            row << academic_year.range
            survey_items.each do |survey_item_id|
              survey_item = survey_items_by_id[survey_item_id]
              if sufficient_survey_items[grade].include? survey_item_id
                row.append("#{survey_item.survey_item_responses.where(school:, academic_year:,
                                                                      grade:).average(:likert_score).to_f.round(2)}")
              else
                row.append("N/A")
              end
            end
            data << row
          end

          # now iterate through all survey items again
          # if the whole school has sufficient responses, write the school avg
          # else, N/A
          row = []
          row.append(school.name)
          row.append("All School")
          row.append(academic_year.range)
          survey_items.each do |survey_item_id|
            survey_item = survey_items_by_id[survey_item_id]
            # filter out response rate at subcategory level <24.5% for school average
            subcategory = survey_item.scale.measure.subcategory
            if ::StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).meets_student_threshold?
              row.append("#{survey_item.survey_item_responses.where(
                # We allow the nil (unknown) grades in the school survey item average
                # also filter less than 10 responses in the whole school
                'school_id = ? and academic_year_id = ? and (grade IS NULL or grade IN (?))', school.id, academic_year.id, school.grades(academic_year:)
              ).group('survey_item_id').having('count(*) >= 10').average(:likert_score).values[0].to_f.round(2)}")
            else
              row.append("N/A")
            end
          end
          data << row
        end
      end

      CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
    end

    def self.write_csv(csv:, filepath:)
      File.write(filepath, csv)
    end
  end
end
