module Analyze
  module Source
    class AllData
      attr_reader :slices

      include Analyze::Slice

      def initialize(slices:)
        @slices = slices
      end

      def to_s
        'All Data'
      end

      def slug
        'all-data'
      end
    end
  end
end
