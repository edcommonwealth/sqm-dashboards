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
        [Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student,
         Analyze::Graph::Column::Student]
      end
    end
  end
end
