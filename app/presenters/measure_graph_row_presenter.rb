class MeasureGraphRowPresenter
  include Comparable

  attr_reader :score

  def initialize(measure:, score:)
    @measure = measure
    @score = score
  end

  def sufficient_data?
    @score != nil
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
    when :no_zone
      -100
    end
  end

  def <=>(other_presenter)
    order <=> other_presenter.order
  end

  private

  IDEAL_ZONE_WIDTH_PERCENTAGE = 0.2
  APPROVAL_ZONE_WIDTH_PERCENTAGE = 0.2
  GROWTH_ZONE_WIDTH_PERCENTAGE = 0.2
  WATCH_ZONE_WIDTH_PERCENTAGE = 0.2
  WARNING_ZONE_WIDTH_PERCENTAGE = 0.2

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
    scale = Scale.new(
      watch_low_benchmark: @measure.watch_low_benchmark,
      growth_low_benchmark: @measure.growth_low_benchmark,
      approval_low_benchmark: @measure.approval_low_benchmark,
      ideal_low_benchmark: @measure.ideal_low_benchmark,
    )
    scale.zone_for_score(@score)
  end
end
