# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByGrade
      include Analyze::Graph::Column::Grade
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
            array << column_for_grade_code(code: grade)
          end
          array << Analyze::Graph::Column::AllStudent
        end
      end

      private

      def column_for_grade_code(code:)
        CFR[code]
      end

      CFR = {
        0 => Zero,
        1 => One,
        2 => Two,
        3 => Three,
        4 => Four,
        5 => Five,
        6 => Six,
        7 => Seven,
        8 => Eight,
        9 => Nine,
        10 => Ten,
        11 => Eleven,
        12 => Twelve
      }.freeze
    end
  end
end
