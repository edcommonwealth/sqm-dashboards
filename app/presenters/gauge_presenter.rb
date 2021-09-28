class GaugePresenter
  def initialize(scale:, score:)
    @scale = scale
    @score = score
  end

  def title
    zone.type.to_s.capitalize
  end

  def color_class
    "fill-#{zone.type}"
  end

  def score_percentage
    percentage_for @score
  end

  def key_benchmark_percentage
    percentage_for @scale.approval_zone.low_benchmark
  end

  private

  def zone
    @scale.zone_for_score(@score)
  end

  def percentage_for(number)
    scale_minimum = @scale.warning_zone.low_benchmark
    scale_maximum = @scale.ideal_zone.high_benchmark
    (number - scale_minimum) / (scale_maximum - scale_minimum)
  end
end
