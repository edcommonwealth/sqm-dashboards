module Report
  class SurveyItem
    def self.create_grade_report(school:, academic_year:, filename:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      # get list of survey items with sufficient responses
      survey_items = Set.new
      # also get a map of grade->survey_id
      sufficient_survey_items = {}
      school.grades(academic_year:).each do |grade|
        sufficient_survey_items[grade] ||= Set.new
      end
      ::SurveyItemResponse.student_survey_items_with_responses_by_grade(
        school:,
        academic_year:
      ).select do |key, _value|
        use_student_survey_items.include?(key[1])
      end.each do |key, count|
        # key[1] is survey item id
        next if key[0].nil?

        survey_items.add(key[1])
        sufficient_survey_items[key[0]].add(key[1]) if count >= 10
      end
      # write headers
      headers = [
        "School Name",
        "Grade"
      ]
      survey_items.each do |survey_item_id|
        headers << ::SurveyItem.find_by_id(survey_item_id).prompt
      end
      data = []
      data << headers
      # for each grade, iterate through all survey items in our list
      # if it has sufficient responses, write out the avg score
      # else, write 'N/A'
      school.grades(academic_year:).sort.each do |grade|
        next if grade == -1 # skip pre-k

        row = []
        row << school.name
        if grade == 0
          row.append("Kindergarten")
        else
          row.append("Grade #{grade}")
        end
        survey_items.each do |survey_item_id|
          survey_item = ::SurveyItem.find_by_id survey_item_id
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
      survey_items.each do |survey_item_id|
        survey_item = ::SurveyItem.find_by_id survey_item_id
        # filter out response rate at subcategory level <24.5% for school average
        scale = Scale.find_by_id(survey_item.scale_id)
        measure = ::Measure.find_by_id(scale.measure_id)
        subcategory = ::Subcategory.find_by_id(measure.subcategory_id)
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
      # write out file
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.create_item_report(school:, academic_year:, filename:, use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
      # first, determine headers by finding the school and grades
      # Q: Should a grade not be included if it has no sufficient responses?
      # A: Include all grades, except preschool

      # Convert they keys in this hash to a hash where the key is the grade
      # and the value is a set of sufficient survey IDs
      survey_ids_to_grades = {}
      ::SurveyItemResponse.student_survey_items_with_responses_by_grade(
        school:,
        academic_year:
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
        "Survey Population"
      ]
      school.grades(academic_year:).sort.each do |value|
        next if value == -1

        if value == 0
          headers.append("Kindergarten")
        else
          headers.append("Grade #{value}")
        end
      end
      headers.append("#{school.name}")
      # Then, add the headers to data
      data = []
      data << headers
      # for each survey item id
      survey_ids_to_grades.each do |id, grades|
        row = []
        survey_item = ::SurveyItem.find_by_id(id)
        row.concat(survey_item_info(survey_item:)) # fills prompt + categories
        row.append("Students")
        school.grades(academic_year:).sort.each do |grade|
          next if grade == -1

          if grades.include?(grade)
            # we already know grade has sufficient responses
            row.append("#{survey_item.survey_item_responses.where(school:, academic_year:,
                                                                  grade:).average(:likert_score).to_f.round(2)}")
          else
            row.append("N/A")
          end
        end
        # filter out response rate at subcategory level <24.5% for school average
        scale = Scale.find_by_id(survey_item.scale_id)
        measure = ::Measure.find_by_id(scale.measure_id)
        subcategory = ::Subcategory.find_by_id(measure.subcategory_id)
        if ::StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).meets_student_threshold?
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
        survey_item = ::SurveyItem.find_by_id(key)
        row.concat(survey_item_info(survey_item:))
        row.append("Teacher")
        # we need to add padding to skip the grades columns
        # we also need to remove another column if the school teaches preschool, which we skip entirely
        preschool_adjustment = school.grades(academic_year:).include?(-1) ? 1 : 0
        padding = Array.new(school.grades(academic_year:).length - preschool_adjustment) { "" }
        row.concat(padding)
        # we already know that the survey item we are looking at has sufficient responses
        row.append("#{survey_item.survey_item_responses.where(school:,
                                                              academic_year:).average(:likert_score).to_f.round(2)}")
        data << row
      end
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.write_csv(data:, filepath:)
      csv = CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
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
