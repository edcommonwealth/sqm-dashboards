# frozen_string_literal: true

class AnalyzeBarPresenter
  include AnalyzeHelper
  attr_reader :score, :x_position, :academic_year, :measure_id, :measure, :color

  MINIMUM_BAR_HEIGHT = 2

  def initialize(measure:, academic_year:, score:, x_position:, color:)
    @score = score
    @x_position = x_position
    @academic_year = academic_year
    @measure = measure
    @measure_id = measure.measure_id
    @color = color
  end

  def y_offset
    case zone.type
    when :ideal, :approval
      (analyze_zone_height * 2) - bar_height_percentage
    else
      (analyze_zone_height * 2)
    end
  end

  def bar_color
    "fill-#{zone.type}"
  end

  def bar_height_percentage
    bar_height = case zone.type
                 when :ideal
                   (percentage * zone_height_percentage + zone_height_percentage) * 100
                 when :approval
                   (percentage * zone_height_percentage) * 100
                 when :growth
                   ((1 - percentage) * zone_height_percentage) * 100
                 when :watch
                   ((1 - percentage) * zone_height_percentage + zone_height_percentage) * 100
                 when :warning
                   ((1 - percentage) * zone_height_percentage + zone_height_percentage + zone_height_percentage) * 100
                 else
                   0.0
                 end
    enforce_minimum_height(bar_height:)
  end

  def percentage
    low_benchmark = zone.low_benchmark
    (score.average - low_benchmark) / (zone.high_benchmark - low_benchmark)
  end

  def zone
    zones = Zones.new(
      watch_low_benchmark: measure.watch_low_benchmark,
      growth_low_benchmark: measure.growth_low_benchmark,
      approval_low_benchmark: measure.approval_low_benchmark,
      ideal_low_benchmark: measure.ideal_low_benchmark
    )
    zones.zone_for_score(score.average)
  end

  def average
    average = score.average
    return 0 if average.nil?

    average.round(6)
  end

  private

  def enforce_minimum_height(bar_height:)
    bar_height < MINIMUM_BAR_HEIGHT ? MINIMUM_BAR_HEIGHT : bar_height
  end
end
