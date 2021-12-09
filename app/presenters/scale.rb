class Scale
  def initialize(watch_low_benchmark:, growth_low_benchmark:, approval_low_benchmark:, ideal_low_benchmark:)
    @watch_low_benchmark = watch_low_benchmark
    @growth_low_benchmark = growth_low_benchmark
    @approval_low_benchmark = approval_low_benchmark
    @ideal_low_benchmark = ideal_low_benchmark
    @warning_low_benchmark = 1
  end

  Zone = Struct.new(:low_benchmark, :high_benchmark, :type)

  def warning_zone
    Zone.new(1, @watch_low_benchmark, :warning)
  end

  def watch_zone
    Zone.new(@watch_low_benchmark, @growth_low_benchmark, :watch)
  end

  def growth_zone
    Zone.new(@growth_low_benchmark, @approval_low_benchmark, :growth)
  end

  def approval_zone
    Zone.new(@approval_low_benchmark, @ideal_low_benchmark, :approval)
  end

  def ideal_zone
    Zone.new(@ideal_low_benchmark, 5.0, :ideal)
  end

  def insufficient_data
    Zone.new(0,@warning_low_benchmark,:insufficient_data)
  end

  def zone_for_score(score)
    case score
    when nil
      insufficient_data
    when ideal_zone.low_benchmark..ideal_zone.high_benchmark
      ideal_zone
    when approval_zone.low_benchmark..approval_zone.high_benchmark
      approval_zone
    when growth_zone.low_benchmark..growth_zone.high_benchmark
      growth_zone
    when watch_zone.low_benchmark..watch_zone.high_benchmark
      watch_zone
    when 1..warning_zone.high_benchmark
      warning_zone
    else
      insufficient_data
    end
  end
end
