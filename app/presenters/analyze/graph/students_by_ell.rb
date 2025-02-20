# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByEll
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
            array << Analyze::Graph::Column::Ell.new(ell:)
          end
          array.sort_by!(&:label)
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
