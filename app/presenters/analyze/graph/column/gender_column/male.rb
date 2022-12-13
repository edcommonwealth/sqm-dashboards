# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module GenderColumn
        class Male < GroupedBarColumnPresenter
          include Analyze::Graph::Column::GenderColumn::ScoreForGender
          def label
            'Male'
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

          def gender
            ::Gender.find_by_qualtrics_code 2
          end
        end
      end
    end
  end
end
