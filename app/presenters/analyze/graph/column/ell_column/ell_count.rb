module Analyze
  module Graph
    module Column
      module EllColumn
        module EllCount
          def type
            :student
          end

          def n_size(year_index)
            SurveyItemResponse.where(ell:, survey_item: measure.student_survey_items, school:, grade: grades(year_index),
                                     academic_year: academic_years[year_index]).select(:response_id).distinct.count
          end
        end
      end
    end
  end
end
