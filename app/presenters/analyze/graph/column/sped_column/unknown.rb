# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module SpedColumn
        class Unknown < GroupedBarColumnPresenter
          include Analyze::Graph::Column::SpedColumn::ScoreForSped
          include Analyze::Graph::Column::SpedColumn::SpedCount

          def label
            %w[Unknown]
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

          def sped
            ::Sped.find_by_slug "unknown"
          end
        end
      end
    end
  end
end
