module Analyze
  module Group
    class Race
      def name
        "Race"
      end

      def slug
        "race"
      end

      def graph
        Analyze::Graph::StudentsByRace.new(races: nil)
      end
    end
  end
end
