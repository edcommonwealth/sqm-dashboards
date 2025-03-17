module Analyze
  module Source
    class AllData
      attr_reader :slices, :graph

      def initialize(slices:, graph:)
        @slices = slices
        @graph = graph
      end

      def to_s
        "All Data"
      end

      def slug
        "all-data"
      end
    end
  end
end
