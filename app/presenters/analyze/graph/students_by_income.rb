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
            array << column_for_income_code(code: income.slug)
          end
          array << Analyze::Graph::Column::AllStudent
        end
      end

      private

      def column_for_income_code(code:)
        CFR[code.to_s]
      end

      CFR = {
        "economically-disadvantaged-y" => Analyze::Graph::Column::IncomeColumn::Disadvantaged,
        "economically-disadvantaged-n" => Analyze::Graph::Column::IncomeColumn::NotDisadvantaged,
        "unknown" => Analyze::Graph::Column::IncomeColumn::Unknown
      }.freeze
    end
  end
end
