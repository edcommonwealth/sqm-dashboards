module Analyze
  module Slice
    class AllData < Base
      def initialize(graph:, label: "All Data", slug: "all-data")
        super(label:, slug:, graph:)
      end
    end
  end
end
