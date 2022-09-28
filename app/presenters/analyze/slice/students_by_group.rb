module Analyze
  module Slice
    class StudentsByGroup
      attr_reader :races, :grades

      def initialize(races:, grades:)
        @races = races
        @grades = grades
      end

      def to_s
        'Students by Group'
      end

      def slug
        'students-by-group'
      end

      def graphs
        [Analyze::Graph::StudentsByRace.new(races:), Analyze::Graph::StudentsByGrade.new(grades:)]
      end
    end
  end
end
