module Analyze
  module Graph
    module Column
      module Parent
        class Scale
          attr_reader :scale

          def initialize(scale:)
            @scale = scale
          end

          def label
            scale.name.split("-")
          end

          def basis
            "parent data"
          end

          def show_irrelevancy_message?(construct:)
            false
          end

          def show_insufficient_data_message?(construct:, school:, academic_years:)
            false
          end

          def insufficiency_message
            ["data not", "available"]
          end

          def score(construct:, school:, academic_year:)
            average = scale.parent_score(school:, academic_year:)
            Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true, meets_admin_data_threshold: true)
          end

          def type
            :parent
          end

          def n_size(construct:, school:, academic_year:)
            SurveyItemResponse.where(survey_item: scale.survey_items.parent_survey_items, school:, academic_year:).select(:response_id).distinct.count
          end
        end
      end
    end
  end
end
