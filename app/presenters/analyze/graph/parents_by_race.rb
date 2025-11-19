# frozen_string_literal: true

module Analyze
  module Graph
    class ParentsByRace
      def to_s
        "Parents by Race"
      end

      def slug
        "parents-by-race"
      end

      def columns
        [].tap do |array|
          Race.all.each do |race|
            label = if race.designation.match(/\or\s/i)
                      [race.designation.split("or").first.squish]
                    else
                      race.designation.split(" ", 2).compact
                    end

            array << Analyze::Graph::Column::Parent::Race.new(races: race, label:, show_irrelevancy_message: false)
          end
          array << Analyze::Graph::Column::Parent::Race.new(races: Race.all, label: ["All", "Parents"], show_irrelevancy_message: true)
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil, graph: self)
      end

      def slice
        Analyze::Slice::ParentsByGroup.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: "Student Race", slug: "student-race", graph: self)
      end
    end
  end
end
