module Analyze
  module Slice
    class ParentsByGroup < Base
      def initialize(graph:, label: "Parents by Group", slug: "parents-by-group")
        super(label:, slug:, graph:)
      end
    end
  end
end
