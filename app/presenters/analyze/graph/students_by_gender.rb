# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByGender
      include Analyze::Graph::Column::GenderColumn
      attr_reader :genders

      def initialize(genders:)
        @genders = genders
      end

      def to_s
        "Students by Gender"
      end

      def slug
        "students-by-gender"
      end

      def columns
        [].tap do |array|
          genders.each do |gender|
            array << column_for_gender_code(code: gender.qualtrics_code)
          end
          array.sort_by!(&:to_s)
          array << Analyze::Graph::Column::AllStudent
        end
      end

      private

      def column_for_gender_code(code:)
        CFR[code]
      end

      CFR = {
        1 => Analyze::Graph::Column::GenderColumn::Female,
        2 => Analyze::Graph::Column::GenderColumn::Male,
        4 => Analyze::Graph::Column::GenderColumn::NonBinary,
        99 => Analyze::Graph::Column::GenderColumn::Unknown
      }.freeze
    end
  end
end
