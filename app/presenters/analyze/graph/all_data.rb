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
        Analyze::Source::AllData.new(slices: [slice], graph: self)
      end

      def slice
        Analyze::Slice::AllData.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: nil, slug: nil, graph: nil)
      end

      def show_irrelevancy_message?(construct:)
        false
      end

      def show_insufficient_data_message?(construct:, school:, academic_years:)
        scores = academic_years.map do |academic_year|
          construct.score(school:, academic_year:)
        end

        scores.none? { |score| score.meets_student_threshold? || score.meets_teacher_threshold? || score.meets_admin_data_threshold? }
      end

      def insufficiency_message
        ["survey response", "rate below 25%"]
      end

      def score(construct:, school:, academic_year:)
        construct.score(school:, academic_year:)
      end
    end
  end
end
