# frozen_string_literal: true

module Analyze
  class BarPresenter
    include AnalyzeHelper
    attr_reader :score, :x_position, :academic_year, :construct_id, :construct, :color

    MINIMUM_BAR_HEIGHT = 2

    def initialize(construct:, construct_id:, academic_year:, score:, x_position:, color:)
      @score = score
      @x_position = x_position
      @academic_year = academic_year
      @construct = construct
      @construct_id = construct_id
      @color = color
    end

    def y_offset
      benchmark_height = analyze_zone_height * 2
      case zone.type
      when :ideal, :approval
        benchmark_height - bar_height_percentage
      else
        benchmark_height
      end
    end

    def bar_color
      "fill-#{zone.type}"
    end

    def bar_height_percentage
      bar_height = send("#{zone.type}_bar_height_percentage") || 0
      enforce_minimum_height(bar_height:)
    end

    def percentage
      low_benchmark = zone.low_benchmark
      (score.average - low_benchmark) / (zone.high_benchmark - low_benchmark)
    end

    Zone = Struct.new(:low_benchmark, :high_benchmark, :type)
    def zone
      zones = Zones.new(
        watch_low_benchmark: construct.watch_low_benchmark,
        growth_low_benchmark: construct.growth_low_benchmark,
        approval_low_benchmark: construct.approval_low_benchmark,
        ideal_low_benchmark: construct.ideal_low_benchmark
      )
      zones.zone_for_score(score.average)
    end

    def average
      average = score.average || 0

      average.round(6)
    end

    private

    def enforce_minimum_height(bar_height:)
      bar_height < MINIMUM_BAR_HEIGHT ? MINIMUM_BAR_HEIGHT : bar_height
    end

    def ideal_bar_height_percentage
      (percentage * zone_height_percentage + zone_height_percentage) * 100
    end

    def approval_bar_height_percentage
      (percentage * zone_height_percentage) * 100
    end

    def growth_bar_height_percentage
      ((1 - percentage) * zone_height_percentage) * 100
    end

    def watch_bar_height_percentage
      ((1 - percentage) * zone_height_percentage + zone_height_percentage) * 100
    end

    def warning_bar_height_percentage
      ((1 - percentage) * zone_height_percentage + zone_height_percentage + zone_height_percentage) * 100
    end
  end
end
