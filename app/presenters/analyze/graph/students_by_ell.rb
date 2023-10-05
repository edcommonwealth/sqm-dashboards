# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByEll
      include Analyze::Graph::Column::EllColumn
      attr_reader :ells

      def initialize(ells:)
        @ells = ells
      end

      def to_s
        "Students by Ell"
      end

      def slug
        "students-by-ell"
      end

      def columns
        [].tap do |array|
          ells.each do |ell|
            array << column_for_ell_code(code: ell.slug)
          end
          array.sort_by!(&:to_s)
          array << Analyze::Graph::Column::AllStudent
        end
      end

      private

      def column_for_ell_code(code:)
        CFR[code]
      end

      CFR = {
        "ell" => Analyze::Graph::Column::EllColumn::Ell,
        "not-ell" => Analyze::Graph::Column::EllColumn::NotEll,
        "unknown" => Analyze::Graph::Column::EllColumn::Unknown
      }.freeze
    end
  end
end
