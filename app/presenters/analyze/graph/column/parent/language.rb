module Analyze
  module Graph
    module Column
      module Parent
      class Language < ColumnBase
        attr_reader :parent

        def initialize(parent:)
          @parent = parent
        end

        def label
          ["#{parent.designation}"]
        end

        def basis
          "parent"
        end

        def show_irrelevancy_message?(measure:)
          false
        end

        def show_insufficient_data_message?(measure:, school:, academic_years:)
          false
        end

        def type
          :parent
        end

        def n_size(measure:, school:, academic_year:)
          SurveyItemResponse.where( survey_item: measure.parent_survey_items, school:,  academic_year:),
                                   academic_year:).select(:response_id).distinct.count
        end

        def score(measure:, school:, academic_year:)
          Score.new(average: 3,
                    meets_teacher_threshold: false,
                    meets_student_threshold:,
                    meets_admin_data_threshold: false)
        end
      end
    end
  end
end
