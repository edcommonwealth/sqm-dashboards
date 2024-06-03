module Analyze
  module Graph
    module Column
      module SpedColumn
        module SpedCount
          def type
            :student
          end

          def n_size(academic_year)
            SurveyItemResponse.where(sped:, survey_item: measure.student_survey_items, school:, grade: grades,
                                     academic_year:).select(:response_id).distinct.count
          end
        end
      end
    end
  end
end
