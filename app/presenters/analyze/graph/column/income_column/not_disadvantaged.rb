# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module IncomeColumn
        class NotDisadvantaged < GroupedBarColumnPresenter
          include Analyze::Graph::Column::IncomeColumn::ScoreForIncome
          include Analyze::Graph::Column::IncomeColumn::IncomeCount
          def label
            ["Not Economically", "Disadvantaged"]
          end

          def show_irrelevancy_message?
            false
          end

          def show_insufficient_data_message?
            false
          end

          def income
            Income.find_by_designation "Economically Disadvantaged - N"
          end
        end
      end
    end
  end
end
