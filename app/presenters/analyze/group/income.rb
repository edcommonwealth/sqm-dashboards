module Analyze
  module Group
    class Income
      def name
        "Income"
      end

      def slug
        "income"
      end

      def graph
        Analyze::Graph::StudentsByIncome.new(incomes: nil)
      end
    end
  end
end
