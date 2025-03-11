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

          def show_irrelevancy_message?(measure:)
            false
          end

          def show_insufficient_data_message?(measure:, school:, academic_years:)
            false
          end

          def insufficiency_message
            ["data not", "available"]
          end

          def score(measure:, school:, academic_year:)
            average = scale.parent_score(school:, academic_year:)
            Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true, meets_admin_data_threshold: true)
          end

          def type
            :parent
          end
        end
      end
    end
  end
end
