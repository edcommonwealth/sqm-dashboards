module Analyze
  module Slice
    class Base
      attr_reader :graph, :label, :slug

      def initialize(label:, slug:, graph:)
        @label = label
        @slug = slug
        @graph = graph
      end

      def to_s
        label
      end
    end
  end
end
