# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByGrade
      attr_reader :grades

      def initialize(grades:)
        @grades = grades
      end

      def to_s
        "Students by Grade"
      end

      def slug
        "students-by-grade"
      end

      def columns
        [].tap do |array|
          grades.each do |grade|
            array << Analyze::Graph::Column::Grade.new(grade: grade)
          end
          array << Analyze::Graph::Column::AllStudent.new
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil)
      end

      def slice
        Analyze::Slice::StudentsByGroup.new
      end
    end
  end
end
