# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsBySped
      include Analyze::Graph::Column::SpedColumn
      attr_reader :speds

      def initialize(speds:)
        @speds = speds
      end

      def to_s
        "Students by SpEd"
      end

      def slug
        "students-by-sped"
      end

      def columns
        [].tap do |array|
          speds.each do |sped|
            array << column_for_sped_code(code: sped.slug)
          end
          array << Analyze::Graph::Column::AllStudent
        end
      end

      private

      def column_for_sped_code(code:)
        CFR[code]
      end

      CFR = {
        "special-education" => Analyze::Graph::Column::SpedColumn::Sped,
        "not-special-education" => Analyze::Graph::Column::SpedColumn::NotSped,
        "unknown" => Analyze::Graph::Column::SpedColumn::Unknown
      }.freeze
    end
  end
end
