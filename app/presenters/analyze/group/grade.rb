module Analyze
  module Group
    class Grade
      def name
        "Grade"
      end

      def slug
        "grade"
      end

      def graph
        Analyze::Graph::StudentsByGrade.new(grades: nil)
      end
    end
  end
end
