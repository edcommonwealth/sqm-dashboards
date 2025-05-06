# frozen_string_literal: true

module Analyze
  module Graph
    class AllParent
      def to_s
        "All Parent"
      end

      def slug
        "all-parent"
      end

      def columns(construct:)
        construct.scales.parent_scales.map do |scale|
          Analyze::Graph::Column::Parent::Scale.new(scale:)
        end
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
