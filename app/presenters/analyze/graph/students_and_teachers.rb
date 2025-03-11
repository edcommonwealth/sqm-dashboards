# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsAndTeachers
      include Analyze::Graph::Column
      def to_s
        "Students & Teachers"
      end

      def slug
        "students-and-teachers"
      end

      def columns
        [AllStudent.new, AllTeacher.new, AllSurveyData.new]
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil)
      end

      def slice
        Analyze::Slice::StudentsAndTeachers.new
      end
    end
  end
end
