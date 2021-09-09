module ConstructGraphParameters
  TOTAL_GRAPH_WIDTH = 1152
  GRAPH_WIDTH = 0.75 * TOTAL_GRAPH_WIDTH
  CONSTRUCT_ROW_HEIGHT = 40
  CONSTRUCT_ROW_BAR_HEIGHT = 20

  module ZoneColor
    WARNING = "#FF73C0"
    WATCH = "#F096AD"
    GROWTH = "#E0BA9A"
    APPROVAL = "#D0DD86"
    IDEAL = "#C0FF73"
  end

  class ZoneParams
    attr_reader :left_edge
    attr_reader :width

    def initialize(left_edge:, width:)
      @left_edge = left_edge
      @width = width
    end

    def right_edge
      left_edge + width
    end
  end

  WARNING_ZONE = ZoneParams.new left_edge: 0, width: (GRAPH_WIDTH / 2) / 3
  WATCH_ZONE = ZoneParams.new left_edge: WARNING_ZONE.right_edge, width: (GRAPH_WIDTH / 2) / 3
  GROWTH_ZONE = ZoneParams.new left_edge: WATCH_ZONE.right_edge, width: (GRAPH_WIDTH / 2) / 3
  APPROVAL_ZONE = ZoneParams.new left_edge: GROWTH_ZONE.right_edge, width: (GRAPH_WIDTH / 2) / 2
  IDEAL_ZONE = ZoneParams.new left_edge: APPROVAL_ZONE.right_edge, width: (GRAPH_WIDTH / 2) / 2

  KEY_BENCHMARK_WIDTH = 2
end
