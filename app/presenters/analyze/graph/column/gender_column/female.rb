# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module GenderColumn
        class Female < GroupedBarColumnPresenter
          include Analyze::Graph::Column::GenderColumn::ScoreForGender
          include Analyze::Graph::Column::GenderColumn::GenderCount
          def label
            %w[Female]
          end

          def basis
            "student"
          end

          def show_irrelevancy_message?
            false
          end

          def show_insufficient_data_message?
            false
          end

          def gender
            ::Gender.find_by_qualtrics_code 1
          end
        end
      end
    end
  end
end
