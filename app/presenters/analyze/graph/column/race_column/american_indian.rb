# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module RaceColumn
        class AmericanIndian < GroupedBarColumnPresenter
          include Analyze::Graph::Column::ScoreForRace
          include Analyze::Graph::Column::RaceColumn::RaceCount
          def label
            %w[American Indian]
          end

          def show_irrelevancy_message?
            false
          end

          def show_insufficient_data_message?
            false
          end

          def race
            Race.find_by_qualtrics_code 1
          end
        end
      end
    end
  end
end
