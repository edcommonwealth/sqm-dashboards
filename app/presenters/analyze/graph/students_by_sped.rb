# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsBySped
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
            array << Analyze::Graph::Column::Sped.new(sped:)
          end
          array << Analyze::Graph::Column::AllStudent.new
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil, graph: self)
      end

      def slice
        Analyze::Slice::StudentsByGroup.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: "Special Education", slug: "sped", graph: self)
      end
    end
  end
end
