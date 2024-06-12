# frozen_string_literal: true

module Analyze
  module Graph
    class AllData
      include Analyze::Graph::Column

      def to_s
        "All Data"
      end

      def slug
        "all-data"
      end

      def columns
        [AllStudent, AllTeacher, AllAdmin, Analyze::Graph::Column::AllData]
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
