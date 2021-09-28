class MeasureGraphRowPresenter
  def initialize(measure:, score:)
    @measure = measure
    @score = score
  end

  def measure_name
    @measure.name
  end

  def measure_id
    @measure.measure_id
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
      "50%"
    else
      "#{((0.5 - bar_width_percentage) * 100).round(2)}%"
    end
  end

  private

  IDEAL_ZONE_WIDTH_PERCENTAGE = 0.5 / 2
  APPROVAL_ZONE_WIDTH_PERCENTAGE = 0.5 / 2
  GROWTH_ZONE_WIDTH_PERCENTAGE = 0.5 / 3
  WATCH_ZONE_WIDTH_PERCENTAGE = 0.5 / 3
  WARNING_ZONE_WIDTH_PERCENTAGE = 0.5 / 3

  def bar_width_percentage
    case zone.type
    when :ideal
      percentage * IDEAL_ZONE_WIDTH_PERCENTAGE + APPROVAL_ZONE_WIDTH_PERCENTAGE
    when :approval
      percentage * APPROVAL_ZONE_WIDTH_PERCENTAGE
    when :growth
      (1 - percentage) * GROWTH_ZONE_WIDTH_PERCENTAGE
    when :watch
      (1 - percentage) * WATCH_ZONE_WIDTH_PERCENTAGE + GROWTH_ZONE_WIDTH_PERCENTAGE
    else
      (1 - percentage) * WARNING_ZONE_WIDTH_PERCENTAGE + WATCH_ZONE_WIDTH_PERCENTAGE + GROWTH_ZONE_WIDTH_PERCENTAGE
    end
  end

  def percentage
    (@score - zone.low_benchmark) / (zone.high_benchmark - zone.low_benchmark)
  end

  def zone
    @measure.zone_for_score(@score)
  end
end
