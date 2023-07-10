module Seeders
  class Journey
    def seed
      school = School.first
      academic_year = AcademicYear.last
      SurveyItem.all.each do |survey_item|
        20.times do |i|
          SurveyItemResponse.create(response_id: "#{i}#{survey_item.survey_item_id}", school:, academic_year:,
                                    likert_score: 5, survey_item:, grade: 1)
        end
      end

      School.all.each do |school|
        AcademicYear.all.each do |academic_year|
          Respondent.create(school:, academic_year:, one: 20)
        end
      end
    end
  end
end
