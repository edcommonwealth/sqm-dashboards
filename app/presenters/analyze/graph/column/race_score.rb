module Analyze
  module Graph
    module Column
      module RaceScore
        def race_score(measure:, school:, academic_year:, race:)
          survey_items = measure.student_survey_items
          students = StudentRace.where(race:).pluck(:student_id)
          average = SurveyItemResponse.where(school:,
                                             academic_year:,
                                             survey_item: survey_items,
                                             student: students)
                                      .average(:likert_score)
          Score.new(average, true, true, true)
        end
      end
    end
  end
end
