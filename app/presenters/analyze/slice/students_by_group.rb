module Analyze
  module Slice
    class StudentsByGroup
      attr_accessor :graph

      def to_s
        "Students by Group"
      end

      def slug
        "students-by-group"
      end
    end
  end
end
