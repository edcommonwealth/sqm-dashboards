module Analyze
  module Graph
    module Column
      module Grade
        module GradeCount
          def type
            :student
          end

          def n_size(academic_year)
            SurveyItemResponse.where(grade:, survey_item: measure.student_survey_items, school:,
                                     academic_year:).select(:response_id).distinct.count
          end
        end
      end
    end
  end
end
