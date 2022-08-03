# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsAndTeachers
      include Analyze::Graph::Column
      def to_s
        'Students & Teachers'
      end

      def value
        'students-and-teachers'
      end

      def columns
        [Student, Teacher, GroupedBarColumnPresenter]
      end
    end
  end
end
