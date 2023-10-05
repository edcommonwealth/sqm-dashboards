# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module SpedColumn
        class Sped < GroupedBarColumnPresenter
          include Analyze::Graph::Column::SpedColumn::ScoreForSped
          include Analyze::Graph::Column::SpedColumn::SpedCount

          def label
            %w[Special Education]
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
            ::Sped.find_by_slug "special-education"
          end
        end
      end
    end
  end
end
