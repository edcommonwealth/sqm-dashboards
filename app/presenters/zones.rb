# frozen_string_literal: true

class Zones
  def initialize(watch_low_benchmark:, growth_low_benchmark:, approval_low_benchmark:, ideal_low_benchmark:)
    @watch_low_benchmark = watch_low_benchmark
    @growth_low_benchmark = growth_low_benchmark
    @approval_low_benchmark = approval_low_benchmark
    @ideal_low_benchmark = ideal_low_benchmark
    @warning_low_benchmark = 1
  end

  Zone = Struct.new(:low_benchmark, :high_benchmark, :type)

  def all_zones
    [
      ideal_zone, approval_zone, growth_zone, watch_zone, warning_zone, insufficient_data
    ]
  end

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
    Zone.new(Float::MIN, Float::MAX, :insufficient_data)
  end

  def zone_for_score(score)
    all_zones.find { |zone| Score.new(average: score).in_zone?(zone:) } || insufficient_data
  end
end
