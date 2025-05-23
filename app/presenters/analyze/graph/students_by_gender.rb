# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByGender
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
            array << Analyze::Graph::Column::Gender.new(gender:)
          end
          array.sort_by!(&:label)
          array << Analyze::Graph::Column::AllStudent.new
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: [slice], graph: self)
      end

      def slice
        Analyze::Slice::StudentsByGroup.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: "Gender", slug: "gender", graph: self)
      end
    end
  end
end
