# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsAndTeachers
      include Analyze::Graph::Column
      def to_s
        'Students & Teachers'
      end

      def slug
        'students-and-teachers'
      end

      def columns
        [AllStudent, AllTeacher, GroupedBarColumnPresenter]
      end
    end
  end
end
