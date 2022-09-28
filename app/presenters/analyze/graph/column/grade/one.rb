# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module Grade
        class One < GroupedBarColumnPresenter
          include Analyze::Graph::Column::Grade::ScoreForGrade
          def label
            'Grade 1'
          end

          def basis
            'student'
          end

          def show_irrelevancy_message?
            false
          end

          def show_insufficient_data_message?
            false
          end

          def grade
            1
          end
        end
      end
    end
  end
end
