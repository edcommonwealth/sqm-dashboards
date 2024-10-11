# frozen_string_literal: true

class Overview::VarianceChartRowPresenter
  include Comparable

  attr_reader :score, :construct_name, :construct_id, :category

  def initialize(construct:, score:)
    @construct = construct
    @score = score.average
    @meets_teacher_threshold = score.meets_teacher_threshold?
    @meets_student_threshold = score.meets_student_threshold?
    @construct_name = @construct.name
    @construct_id = @construct.construct_id
    @category = @construct.category
  end

  def sufficient_data?
    @score != nil
  end

  def bar_color
    "fill-#{zone.type}"
  end

  def bar_width
    "#{(bar_width_percentage * 100).round(2)}%"
  end

  def x_offset
    case zone.type
    when :ideal, :approval
      "60%"
    else
      "#{((0.6 - bar_width_percentage) * 100).abs.round(2)}%"
    end
  end

  def order
    case zone.type
    when :ideal, :approval
      bar_width_percentage
    when :warning, :watch, :growth
      -bar_width_percentage
    when :insufficient_data
      -100
    end
  end

  def <=>(other)
    other.order <=> order
  end

  def show_partial_data_indicator?
    partial_data_sources.present?
  end

  def partial_data_sources
    [].tap do |sources|
      sources << "teacher survey results" if @construct.includes_teacher_survey_items? && !@meets_teacher_threshold
      sources << "student survey results" if @construct.includes_student_survey_items? && !@meets_student_threshold
      sources << "administrative data" if @construct.includes_admin_data_items?
    end
  end

  private

  IDEAL_ZONE_WIDTH_PERCENTAGE = 0.2
  APPROVAL_ZONE_WIDTH_PERCENTAGE = 0.2
  GROWTH_ZONE_WIDTH_PERCENTAGE = 0.2
  WATCH_ZONE_WIDTH_PERCENTAGE = 0.2
  WARNING_ZONE_WIDTH_PERCENTAGE = 0.2

  def bar_width_percentage
    send("#{zone.type}_bar_width_percentage")
  end

  def ideal_bar_width_percentage
    percentage * IDEAL_ZONE_WIDTH_PERCENTAGE + APPROVAL_ZONE_WIDTH_PERCENTAGE
  end

  def approval_bar_width_percentage
    percentage * APPROVAL_ZONE_WIDTH_PERCENTAGE
  end

  def growth_bar_width_percentage
    (1 - percentage) * GROWTH_ZONE_WIDTH_PERCENTAGE
  end

  def watch_bar_width_percentage
    (1 - percentage) * WATCH_ZONE_WIDTH_PERCENTAGE + GROWTH_ZONE_WIDTH_PERCENTAGE
  end

  def warning_bar_width_percentage
    (1 - percentage) * WARNING_ZONE_WIDTH_PERCENTAGE + WATCH_ZONE_WIDTH_PERCENTAGE + GROWTH_ZONE_WIDTH_PERCENTAGE
  end

  def insufficient_data_bar_width_percentage
    0
  end

  def percentage
    low_benchmark = zone.low_benchmark
    (@score - low_benchmark) / (zone.high_benchmark - low_benchmark)
  end

  def zone
    zones = Zones.new(
      watch_low_benchmark: @construct.watch_low_benchmark,
      growth_low_benchmark: @construct.growth_low_benchmark,
      approval_low_benchmark: @construct.approval_low_benchmark,
      ideal_low_benchmark: @construct.ideal_low_benchmark
    )
    zones.zone_for_score(@score)
  end
end
