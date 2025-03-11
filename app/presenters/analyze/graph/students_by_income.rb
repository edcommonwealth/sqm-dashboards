# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByIncome
      attr_reader :incomes

      def initialize(incomes:)
        @incomes = incomes
      end

      def to_s
        "Students by income"
      end

      def slug
        "students-by-income"
      end

      def columns
        [].tap do |array|
          incomes.each do |income|
            array << Analyze::Graph::Column::Income.new(income:)
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
