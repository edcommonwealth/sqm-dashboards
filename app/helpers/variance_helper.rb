# frozen_string_literal: true

module VarianceHelper
  def heading_gutter
    30
  end

  def footer_gutter
    50
  end

  def measure_row_height
    40
  end

  def graph_height(number_of_rows)
    number_of_rows * measure_row_height + heading_gutter + footer_gutter
  end

  def graph_background_height(number_of_rows:)
    number_of_rows += 1 if @has_empty_dataset
    graph_height(number_of_rows) - footer_gutter
  end

  def measure_row_bar_height
    20
  end

  def label_width_percentage
    30
  end

  def graph_width_percentage
    100 - label_width_percentage
  end

  def zones
    %w[warning watch growth approval ideal]
  end

  def zone_width_percentage
    100.0 / zones.size
  end

  def availability_indicator_percentage
    3
  end

  def partial_data_indicator_size
    20
  end
end
