module Analyze
  module Slice
    class StudentsAndTeachersAndParents < Base
      def initialize(graph:, label: "Students, Teachers & Parents", slug: "students-and-teachers-and-pareents")
        super(label:, slug:, graph:)
      end
    end
  end
end
