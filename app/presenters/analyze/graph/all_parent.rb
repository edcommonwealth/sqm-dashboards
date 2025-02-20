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
        Analyze::Source::AllData.new(slices: [slice])
      end

      def slice
        Analyze::Slice::AllData.new
      end
    end
  end
end
