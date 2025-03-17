module Analyze
  module Slice
    class StudentsByGroup < Base
      def initialize(graph:, label: "Students by Group", slug: "students-by-group")
        super(label:, slug:, graph:)
      end
    end
  end
end
