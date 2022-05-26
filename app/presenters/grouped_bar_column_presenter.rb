class GroupedBarColumnPresenter
  include AnalyzeHelper
  attr_reader :score, :measure_name, :measure_id, :category, :position, :type

  def initialize(measure:, score:, position:, type:)
    @measure = measure
    @score = score
    @meets_teacher_threshold = score.meets_teacher_threshold?
    @meets_student_threshold = score.meets_student_threshold?
    @measure_name = @measure.name
    @measure_id = @measure.measure_id
    @category = @measure.subcategory.category
    @position = position
    @type = type
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
    case zone.type
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
  end

  def percentage
    (@score.average - zone.low_benchmark) / (zone.high_benchmark - zone.low_benchmark)
  end

  def zone
    zones = Zones.new(
      watch_low_benchmark: @measure.watch_low_benchmark,
      growth_low_benchmark: @measure.growth_low_benchmark,
      approval_low_benchmark: @measure.approval_low_benchmark,
      ideal_low_benchmark: @measure.ideal_low_benchmark
    )
    zones.zone_for_score(@score.average)
  end

  def label
    case type
    when :all
      'All Survey Data'
    when :student
      'All Students'
    when :teacher
      'All Teachers'
    end
  end

  def show_irrelevancy_message?
    return true if type == :student && !@measure.includes_student_survey_items?

    return true if type == :teacher && !@measure.includes_teacher_survey_items?
    return true if type == :all && !@measure.includes_teacher_survey_items? && !@measure.includes_student_survey_items?

    false
  end

  def show_insufficient_data_message?
    case type
    when :all
      !score.meets_teacher_threshold? && !score.meets_student_threshold?
    when :student
      !score.meets_student_threshold?
    when :teacher
      !score.meets_teacher_threshold?
    else
      false
    end
  end
end
