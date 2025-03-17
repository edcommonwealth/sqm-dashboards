module Analyze
  module Slice
    class StudentsAndTeachers < Base
      def initialize(graph:, label: "Students & Teachers", slug: "students-and-teachers")
        super(label:, slug:, graph:)
      end
    end
  end
end
