class Analyze::BackgroundPresenter
  include AnalyzeHelper
  attr_reader :num_of_columns

  def initialize(num_of_columns:)
    @num_of_columns = num_of_columns
  end

  def zone_label_x
    2
  end

  def benchmark_y
    (analyze_zone_height * 2) - (benchmark_height / 2.0)
  end

  def benchmark_height
    1
  end

  def grouped_chart_column_width
    graph_width / num_of_columns
  end

  def column_end_x(position)
    zone_label_width + (grouped_chart_column_width * position)
  end

  def column_start_x(position)
    column_end_x(position - 1)
  end

  def bar_label_height
    (100 - ((100 - analyze_graph_height) / 2))
  end

  def zone_label_y(position)
    8.5 * (position + position - 1)
  end
end
