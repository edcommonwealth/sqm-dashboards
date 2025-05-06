# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsAndTeachersAndParents
      include Analyze::Graph::Column

      def to_s
        "Students, Teachers & Parents"
      end

      def slug
        "students-and-teachers-and-parents"
      end

      def columns
        [AllStudent.new, AllTeacher.new, AllSurveyData.new]
      end

      def source
        Analyze::Source::SurveyData.new(slices: [slice], graph: self)
      end

      def slice
        Analyze::Slice::StudentsAndTeachersAndParents.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: nil, slug: nil, graph: nil)
      end
    end
  end
end
