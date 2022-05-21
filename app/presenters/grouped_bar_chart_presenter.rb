class GroupedBarChartPresenter
  attr_reader :score

  def initialize(measure:, score:)
    @measure = measure
    @score = score.average
    @meets_teacher_threshold = score.meets_teacher_threshold?
    @meets_student_threshold = score.meets_student_threshold?
    @measure_name = @measure.name
    @measure_id = @measure.measure_id
    @category = @measure.subcategory.category
  end

  IDEAL_ZONE_WIDTH_PERCENTAGE = 0.17
  APPROVAL_ZONE_WIDTH_PERCENTAGE = 0.17
  GROWTH_ZONE_WIDTH_PERCENTAGE = 0.17
  WATCH_ZONE_WIDTH_PERCENTAGE = 0.17
  WARNING_ZONE_WIDTH_PERCENTAGE = 0.17

  def y_offset
    case zone.type
    when :ideal, :approval
      34 - bar_height_percentage * 100
    else
      34
    end
  end

  def bar_height_percentage
    case zone.type
    when :ideal
      percentage * IDEAL_ZONE_WIDTH_PERCENTAGE + APPROVAL_ZONE_WIDTH_PERCENTAGE
    when :approval
      percentage * APPROVAL_ZONE_WIDTH_PERCENTAGE
    when :growth
      (1 - percentage) * GROWTH_ZONE_WIDTH_PERCENTAGE
    when :watch
      (1 - percentage) * WATCH_ZONE_WIDTH_PERCENTAGE + GROWTH_ZONE_WIDTH_PERCENTAGE
    when :warning
      (1 - percentage) * WARNING_ZONE_WIDTH_PERCENTAGE + WATCH_ZONE_WIDTH_PERCENTAGE + GROWTH_ZONE_WIDTH_PERCENTAGE
    else
      0.0
    end
  end

  def percentage
    (@score - zone.low_benchmark) / (zone.high_benchmark - zone.low_benchmark)
  end

  def zone
    zones = Zones.new(
      watch_low_benchmark: @measure.watch_low_benchmark,
      growth_low_benchmark: @measure.growth_low_benchmark,
      approval_low_benchmark: @measure.approval_low_benchmark,
      ideal_low_benchmark: @measure.ideal_low_benchmark
    )
    zones.zone_for_score(@score)
  end
end
