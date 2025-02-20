# frozen_string_literal: true

module Analyze
  module Graph
    class AllData
      include Analyze::Graph::Column

      def label
        ["All", "Data"]
      end

      def to_s
        "All Data"
      end

      def slug
        "all-data"
      end

      def type
        :all_data
      end

      def columns
        [AllStudent.new, AllTeacher.new, AllAdmin.new, AllData.new]
      end

      def source
        Analyze::Source::AllData.new(slices: [slice])
      end

      def slice
        Analyze::Slice::AllData.new
      end

      def show_irrelevancy_message?(measure:)
        false
      end

      def show_insufficient_data_message?(measure:, school:, academic_years:)
        scores = academic_years.map do |academic_year|
          measure.score(school:, academic_year:)
        end

        scores.none? { |score| score.meets_student_threshold? || score.meets_teacher_threshold? || score.meets_admin_data_threshold? }
      end

      def insufficiency_message
        ["survey response", "rate below 25%"]
      end

      def score(measure:, school:, academic_year:)
        measure.score(school:, academic_year:)
      end
    end
  end
end
