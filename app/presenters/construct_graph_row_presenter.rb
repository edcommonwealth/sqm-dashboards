class ConstructGraphRowPresenter
  def initialize(construct:, score:)
    @construct = construct
    @score = score
  end

  def construct_name
    @construct.name
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
    unrounded_bar_width.round
  end

  def x_offset
    case zone.type
    when :ideal, :approval
      0
    else
      -1 * bar_width
    end
  end

  private

  def unrounded_bar_width
    case zone.type
    when :ideal
      percentage * ideal_zone_params.width + approval_zone_params.width
    when :approval
      percentage * approval_zone_params.width
    when :growth
      percentage * growth_zone_params.width
    when :watch
      percentage * watch_zone_params.width + growth_zone_params.width
    else
      percentage * warning_zone_params.width + watch_zone_params.width + growth_zone_params.width
    end
  end

  def percentage
    (@score - zone.low_benchmark) / (zone.high_benchmark - zone.low_benchmark)
  end

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
