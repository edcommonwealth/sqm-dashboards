module AnalyzeHelper
  def zone_label_width
    15
  end

  def zone_label_x
    2
  end

  def analyze_graph_height
    85
  end

  def svg_height
    400
  end

  def graph_width
    85
  end

  def benchmark_y
    (analyze_zone_height * 2) - (benchmark_height / 2.0)
  end

  def benchmark_height
    1
  end

  def grouped_chart_width
    graph_width / data_sources
  end

  def grouped_chart_divider_x(position)
    zone_label_width + (grouped_chart_width * position)
  end

  def bar_label_height
    (100 - ((100 - analyze_graph_height) / 2))
  end

  def bar_label_x(position)
    zone_label_width + (grouped_chart_width * position) - (grouped_chart_width / 2)
  end

  def analyze_zone_height
    analyze_graph_height / 5
  end

  def zone_height_percentage
    analyze_zone_height / 100.0
  end

  def zone_label_y(position)
    8.5 * (position + position - 1)
  end

  def data_sources
    3
  end
end
