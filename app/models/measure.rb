class Measure < ActiveRecord::Base
  belongs_to :subcategory
  has_many :scales
  has_many :admin_data_items, through: :scales
  has_many :survey_items, through: :scales
  has_many :survey_item_responses, through: :survey_items

  def none_meet_threshold?(school:, academic_year:)
    !sufficient_survey_responses?(school:, academic_year:)
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
      meets_admin_data_threshold = all_admin_data_collected?(school:, academic_year:)
      lacks_sufficient_survey_data = !meets_student_threshold && !meets_teacher_threshold
      incalculable_score = lacks_sufficient_survey_data && !includes_admin_data_items?

      next Score.new(nil, false, false, false) if incalculable_score

      scores = []
      scores << collect_survey_scale_average(teacher_scales, school, academic_year) if meets_teacher_threshold
      scores << collect_survey_scale_average(student_scales, school, academic_year) if meets_student_threshold
      scores << collect_admin_scale_average(admin_data_items, school, academic_year) if includes_admin_data_items?

      average = scores.flatten.compact.remove_zeros.average

      next Score.new(nil, false, false, false) if average.nan?

      memo[[school, academic_year]] =
        Score.new(average, meets_teacher_threshold, meets_student_threshold, meets_admin_data_threshold)
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

  def all_admin_data_collected?(school:, academic_year:)
    total_possible_admin_data_items = scales.map { |scale| scale.admin_data_items.count }.sum
    total_collected_admin_data_items = scales.map do |scale|
      scale.admin_data_items.map do |admin_data_item|
        admin_data_item.admin_data_values.where(school:, academic_year:).count
      end
    end.flatten.sum
    total_possible_admin_data_items == total_collected_admin_data_items
  end

  def sufficient_survey_responses?(school:, academic_year:)
    sufficient_student_data?(school:, academic_year:) || sufficient_teacher_data?(school:, academic_year:)
  end

  private

  def collect_survey_scale_average(scales, school, academic_year)
    scales.map { |scale| scale.score(school:, academic_year:) }.average
  end

  def collect_admin_scale_average(scales, school, academic_year)
    scales.map do |admin_data_item|
      admin_value = admin_data_item.admin_data_values.where(school:, academic_year:).first
      admin_value.likert_score if admin_value.present?
    end
  end

  def benchmark(name)
    averages = []
    averages << student_survey_items.first.send(name) if includes_student_survey_items?
    averages << teacher_survey_items.first.send(name) if includes_teacher_survey_items?
    (averages << admin_data_items.map(&name)).flatten! if includes_admin_data_items?
    averages.average
  end
end
