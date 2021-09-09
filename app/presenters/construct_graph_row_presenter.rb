class ConstructGraphRowPresenter

  def initialize(construct:, score:)
    @construct = construct
    @score = score
  end

  def construct_title
    @construct.title
  end

  def bar_color
    case zone.type
    when :ideal
      ConstructGraphParameters::ZoneColor::IDEAL
    when :approval
      ConstructGraphParameters::ZoneColor::APPROVAL
    when :growth
      ConstructGraphParameters::ZoneColor::GROWTH
    when :watch
      ConstructGraphParameters::ZoneColor::WATCH
    else
      ConstructGraphParameters::ZoneColor::WARNING
    end
  end

  def bar_width
    percentage = (@score - zone.low_benchmark) / (zone.high_benchmark - zone.low_benchmark)
    case zone.type
    when :ideal
      (percentage * ideal_zone_params.width + approval_zone_params.width).round
    when :approval
      (percentage * approval_zone_params.width).round
    when :growth
      (percentage * growth_zone_params.width).round
    when :watch
      (percentage * watch_zone_params.width + growth_zone_params.width).round
    else
      (percentage * warning_zone_params.width + watch_zone_params.width + growth_zone_params.width).round
    end
  end

  def x_offset
    case zone.type
    when :ideal, :approval
      0
    else
      bar_width
    end
  end

  private

  def zone
    @construct.zone_for_score(@score)
  end

  def ideal_zone_params
    ConstructGraphParameters::IDEAL_ZONE
  end

  def approval_zone_params
    ConstructGraphParameters::APPROVAL_ZONE
  end

  def growth_zone_params
    ConstructGraphParameters::GROWTH_ZONE
  end

  def watch_zone_params
    ConstructGraphParameters::WATCH_ZONE
  end

  def warning_zone_params
    ConstructGraphParameters::WARNING_ZONE
  end
end
