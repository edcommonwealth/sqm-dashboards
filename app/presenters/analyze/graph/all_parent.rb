# frozen_string_literal: true

module Analyze
  module Graph
    class AllParent
      def initialize(scales:)
        @scales = scales
      end

      def to_s
        "All Data"
      end

      def slug
        "all-data"
      end

      def source
        Analyze::Source::AllData.new(slices: [slice], graph: self)
      end

      def slice
        Analyze::Slice::AllData.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: nil, slug: nil, graph: nil)
      end
    end
  end
end
