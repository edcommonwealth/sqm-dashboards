module Analyze
  module Graph
    class StudentsByGroup
      attr_reader :races

      def initialize(races:)
        @races = races
      end

      def to_s
        'Students by Group'
      end

      def value
        'students-by-group'
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
        '1' => Analyze::Graph::Column::AmericanIndian,
        '2' => Analyze::Graph::Column::Asian,
        '3' => Analyze::Graph::Column::Black,
        '4' => Analyze::Graph::Column::Hispanic,
        '5' => Analyze::Graph::Column::White,
        '8' => Analyze::Graph::Column::MiddleEastern,
        '99' => Analyze::Graph::Column::Unknown,
        '100' => Analyze::Graph::Column::Multiracial
      }
    end
  end
end
