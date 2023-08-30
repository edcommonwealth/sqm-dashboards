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
            array << column_for_race_code(code: race.qualtrics_code)
          end
          array << Analyze::Graph::Column::AllStudent
        end
      end

      private

      def column_for_race_code(code:)
        CFR[code.to_s]
      end

      CFR = {
        "1" => Analyze::Graph::Column::RaceColumn::AmericanIndian,
        "2" => Analyze::Graph::Column::RaceColumn::Asian,
        "3" => Analyze::Graph::Column::RaceColumn::Black,
        "4" => Analyze::Graph::Column::RaceColumn::Hispanic,
        "5" => Analyze::Graph::Column::RaceColumn::White,
        "8" => Analyze::Graph::Column::RaceColumn::MiddleEastern,
        "99" => Analyze::Graph::Column::RaceColumn::Unknown,
        "100" => Analyze::Graph::Column::RaceColumn::Multiracial
      }.freeze
    end
  end
end
