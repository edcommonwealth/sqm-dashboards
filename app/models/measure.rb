class Measure < ActiveRecord::Base
  belongs_to :subcategory
  has_many :scales
  has_many :admin_data_items, through: :scales
  has_many :survey_items, through: :scales
  has_many :survey_item_responses, through: :survey_items

  def none_meet_threshold?(school:, academic_year:)
    !sufficient_data?(school:, academic_year:)
  end

  def teacher_survey_items
    @teacher_survey_items ||= survey_items.teacher_survey_items
  end

  def student_survey_items
    @student_survey_items ||= survey_items.student_survey_items
  end

  def teacher_scales
    @teacher_scales ||= scales.teacher_scales
  end

  def student_scales
    @student_scales ||= scales.student_scales
  end

  def includes_teacher_survey_items?
    teacher_survey_items.any?
  end

  def includes_student_survey_items?
    student_survey_items.any?
  end

  def includes_admin_data_items?
    admin_data_items.any?
  end

  def sources
    sources = []
    sources << :admin_data if includes_admin_data_items?
    sources << :student_surveys if includes_student_survey_items?
    sources << :teacher_surveys if includes_teacher_survey_items?
    sources
  end

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo|
      meets_student_threshold = sufficient_student_data?(school:, academic_year:)
      meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
      next Score.new(nil, false, false) if !meets_student_threshold && !meets_teacher_threshold

      scores = []
      scores << teacher_scales.map { |scale| scale.score(school:, academic_year:) }.average if meets_teacher_threshold
      scores << student_scales.map { |scale| scale.score(school:, academic_year:) }.average if meets_student_threshold
      memo[[school, academic_year]] = Score.new(scores.average, meets_teacher_threshold, meets_student_threshold)
    end

    @score[[school, academic_year]]
  end

  def warning_low_benchmark
    1
  end

  def watch_low_benchmark
    @watch_low_benchmark ||= benchmark(:watch_low_benchmark)
  end

  def growth_low_benchmark
    @growth_low_benchmark ||= benchmark(:growth_low_benchmark)
  end

  def approval_low_benchmark
    @approval_low_benchmark ||= benchmark(:approval_low_benchmark)
  end

  def ideal_low_benchmark
    @ideal_low_benchmark ||= benchmark(:ideal_low_benchmark)
  end

  def sufficient_student_data?(school:, academic_year:)
    return false unless includes_student_survey_items?

    subcategory.student_response_rate(school:, academic_year:).meets_student_threshold?
  end

  def sufficient_teacher_data?(school:, academic_year:)
    return false unless includes_teacher_survey_items?

    subcategory.teacher_response_rate(school:, academic_year:).meets_teacher_threshold?
  end

  def sufficient_data?(school:, academic_year:)
    sufficient_student_data?(school:, academic_year:) || sufficient_teacher_data?(school:, academic_year:)
  end

  private

  def benchmark(name)
    averages = []
    averages << student_survey_items.first.send(name) if includes_student_survey_items?
    averages << teacher_survey_items.first.send(name) if includes_teacher_survey_items?
    (averages << admin_data_items.map(&name)).flatten! if includes_admin_data_items?

    averages.average
  end
end
