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
        [AllStudent, AllTeacher, AllAdmin, GroupedBarColumnPresenter]
      end
    end
  end
end
