# frozen_string_literal: true

module Analyze
  module Graph
    class StudentsByRace
      attr_reader :races

      def initialize(races:)
        @races = races
      end

      def to_s
        "Students by Race"
      end

      def slug
        "students-by-race"
      end

      def columns
        [].tap do |array|
          races.each do |race|
            array << Analyze::Graph::Column::Race.new(race:)
          end
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
        Analyze::Group::Base.new(name: "Race", slug: "race", graph: self)
      end
    end
  end
end
