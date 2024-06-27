module Analyze
  module Graph
    module Column
      module IncomeColumn
        module IncomeCount
          def type
            :student
          end

          def n_size(academic_year)
            SurveyItemResponse.where(income:, survey_item: measure.student_survey_items, school:, grade: grades,
                                     academic_year:).select(:response_id).distinct.count
          end
        end
      end
    end
  end
end
