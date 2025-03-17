module Analyze
  module Source
    class SurveyData
      attr_reader :slices, :graph

      def initialize(slices:, graph:)
        @slices = slices
        @graph = graph
      end

      def to_s
        "Survey Data Only"
      end

      def slug
        "survey-data-only"
      end
    end
  end
end
