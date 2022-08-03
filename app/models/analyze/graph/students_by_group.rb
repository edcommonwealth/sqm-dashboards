module Analyze
  module Graph
    class StudentsByGroup
      def to_s
        'Students by Group'
      end

      def value
        'students-by-group'
      end

      def columns
        [Analyze::Graph::Column::AmericanIndian,
         Analyze::Graph::Column::Asian,
         Analyze::Graph::Column::Black,
         Analyze::Graph::Column::Hispanic,
         Analyze::Graph::Column::MiddleEastern,
         Analyze::Graph::Column::Unknown,
         Analyze::Graph::Column::White,
         Analyze::Graph::Column::Student]
      end
    end
  end
end
