# frozen_string_literal: true

class GaugePresenter
  def initialize(zones:, score:)
    @zones = zones
    @score = score
  end

  def title
    zone.type.to_s.titleize
  end

  def color_class
    "fill-#{zone.type}"
  end

  def score_percentage
    percentage_for @score
  end

  def key_benchmark_percentage
    percentage_for @zones.approval_zone.low_benchmark
  end

  def boundary_percentage_for(zone)
    case zone
    when :watch_low
      watch_low_boundary
    when :growth_low
      growth_low_boundary
    when :ideal_low
      ideal_low_boundary
    end
  end

  attr_reader :score

  private

  def watch_low_boundary
    percentage_for @zones.watch_zone.low_benchmark
  end

  def growth_low_boundary
    percentage_for @zones.growth_zone.low_benchmark
  end

  def approval_low_boundary
    percentage_for @zones.approval_zone.low_benchmark
  end

  def ideal_low_boundary
    percentage_for @zones.ideal_zone.low_benchmark
  end

  def zone
    @zones.zone_for_score(@score)
  end

  def percentage_for(number)
    return nil if number.nil?

    zones_minimum = @zones.warning_zone.low_benchmark
    zones_maximum = @zones.ideal_zone.high_benchmark

    (number - zones_minimum) / (zones_maximum - zones_minimum)
  end
end
