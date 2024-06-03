module Analyze
  module Graph
    module Column
      module RaceColumn
        module RaceCount
          def type
            :student
          end

          def n_size(academic_year)
            SurveyItemResponse.joins("JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id").where(
              school:, academic_year:,
              survey_item: measure.student_survey_items
            ).where("student_races.race_id": race.id).select(:response_id).distinct.count
          end
        end
      end
    end
  end
end
