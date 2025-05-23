# frozen_string_literal: true

class Measure < ActiveRecord::Base
  belongs_to :subcategory, counter_cache: true
  has_one :category, through: :subcategory
  has_many :scales
  has_many :admin_data_items, through: :scales
  has_many :survey_items, through: :scales
  has_many :survey_item_responses, through: :survey_items

  def construct_id
    measure_id
  end

  def none_meet_threshold?(school:, academic_year:)
    @none_meet_threshold ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = !sufficient_survey_responses?(school:, academic_year:)
    end

    @none_meet_threshold[[school, academic_year]]
  end

  def teacher_survey_items
    @teacher_survey_items ||= survey_items.teacher_survey_items
  end

  def student_survey_items
    @student_survey_items ||= survey_items.student_survey_items
  end

  def parent_survey_items
    @parent_survey_items ||= survey_items.parent_survey_items
  end

  def student_survey_items_with_sufficient_responses(school:, academic_year:)
    @student_survey_items_with_sufficient_responses ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = SurveyItem.where(id: SurveyItem.joins("inner join survey_item_responses on survey_item_responses.survey_item_id = survey_items.id")
                                      .student_survey_items
                                      .where("survey_item_responses.school": school,
                                             "survey_item_responses.academic_year": academic_year,
                                             "survey_item_responses.survey_item_id": survey_items.student_survey_items,
                                             "survey_item_responses.grade": school.grades(academic_year:))
                                      .group("survey_items.id")
                                      .having("count(*) >= 10")
                                      .count.keys)
    end
    @student_survey_items_with_sufficient_responses[[school, academic_year]]
  end

  def teacher_scales
    @teacher_scales ||= scales.teacher_scales
  end

  def student_scales
    @student_scales ||= scales.student_scales
  end

  def parent_scales
    @parent_scales ||= scales.parent_scales
  end

  def includes_teacher_survey_items?
    @includes_teacher_survey_items ||= teacher_survey_items.length.positive?
  end

  def includes_student_survey_items?
    @includes_student_survey_items ||= student_survey_items.length.positive?
  end

  def includes_admin_data_items?
    @includes_admin_data_items ||= admin_data_items.length.positive?
  end

  def includes_parent_survey_items?
    @includes_parent_survey_items ||= parent_survey_items.length.positive?
  end

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo, (school, academic_year)|
      next Score::NIL_SCORE if incalculable_score(school:, academic_year:)

      scores = collect_averages_for_teacher_student_and_admin_data(school:, academic_year:)
      average = scores.flatten.compact.remove_blanks.average.round(2)

      next Score::NIL_SCORE if average.nan?

      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end
    @score[[school, academic_year]]
  end

  def student_score(school:, academic_year:)
    @student_score ||= Hash.new do |memo, (school, academic_year)|
      meets_student_threshold = sufficient_student_data?(school:, academic_year:)
      average = student_average(school:, academic_year:).round(2) if meets_student_threshold
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @student_score[[school, academic_year]]
  end

  def teacher_score(school:, academic_year:)
    @teacher_score ||= Hash.new do |memo, (school, academic_year)|
      meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
      average = teacher_average(school:, academic_year:).round(2) if meets_teacher_threshold
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @teacher_score[[school, academic_year]]
  end

  def admin_score(school:, academic_year:)
    @admin_score ||= Hash.new do |memo, (school, academic_year)|
      meets_admin_threshold = sufficient_admin_data?(school:, academic_year:)
      average = admin_data_averages(school:, academic_year:).average.round(2) if meets_admin_threshold
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @admin_score[[school, academic_year]]
  end

  def parent_score(school:, academic_year:)
    @parent_score ||= Hash.new do |memo, (school, academic_year)|
      average = parent_averages(school:, academic_year:).average.round(2)
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @parent_score[[school, academic_year]]
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

  def sufficient_admin_data?(school:, academic_year:)
    any_admin_data_collected?(school:, academic_year:)
  end

  def benchmark(name)
    averages = []
    averages << student_survey_items.first.send(name) if includes_student_survey_items?
    averages << teacher_survey_items.first.send(name) if includes_teacher_survey_items?
    (averages << admin_data_items.map(&name)).flatten! if includes_admin_data_items?
    averages.average
  end

  def zone(school:, academic_year:)
    zone_for_score(score: score(school:, academic_year:))
  end

  def student_zone(school:, academic_year:)
    zone_for_score(score: student_score(school:, academic_year:))
  end

  def teacher_zone(school:, academic_year:)
    zone_for_score(score: teacher_score(school:, academic_year:))
  end

  def admin_zone(school:, academic_year:)
    zone_for_score(score: admin_score(school:, academic_year:))
  end

  def zone_for_score(score:)
    Zones.new(watch_low_benchmark:, growth_low_benchmark:,
              approval_low_benchmark:, ideal_low_benchmark:).zone_for_score(score.average)
  end

  def construct_id
    measure_id
  end

  private

  def any_admin_data_collected?(school:, academic_year:)
    total_collected_admin_data_items =
      admin_data_items.map do |admin_data_item|
        admin_data_item.admin_data_values.where(school:, academic_year:).count
      end.flatten.sum
    total_collected_admin_data_items.positive?
  end

  def sufficient_survey_responses?(school:, academic_year:)
    sufficient_student_data?(school:, academic_year:) || sufficient_teacher_data?(school:, academic_year:)
  end

  def scorify(average:, school:, academic_year:)
    meets_student_threshold = sufficient_student_data?(school:, academic_year:)
    meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
    meets_admin_data_threshold = any_admin_data_collected?(school:, academic_year:)
    Score.new(average:, meets_teacher_threshold:, meets_student_threshold:, meets_admin_data_threshold:)
  end

  def collect_survey_item_average(survey_items:, school:, academic_year:)
    averages = survey_items.map do |survey_item|
      SurveyItemResponse.grouped_responses(school:, academic_year:)[survey_item.id]
    end.remove_blanks
    averages.average || 0
  end

  def sufficient_student_data?(school:, academic_year:)
    return false unless includes_student_survey_items?

    subcategory.response_rate(school:, academic_year:).meets_student_threshold?
  end

  def sufficient_teacher_data?(school:, academic_year:)
    return false unless includes_teacher_survey_items?

    subcategory.response_rate(school:, academic_year:).meets_teacher_threshold?
  end

  def incalculable_score(school:, academic_year:)
    lacks_sufficient_survey_data = !sufficient_student_data?(school:, academic_year:) &&
                                   !sufficient_teacher_data?(school:, academic_year:)
    lacks_sufficient_survey_data && !includes_admin_data_items?
  end

  def collect_averages_for_teacher_student_and_admin_data(school:, academic_year:)
    scores = []
    scores << teacher_average(school:, academic_year:) if sufficient_teacher_data?(school:, academic_year:)
    scores << student_average(school:, academic_year:) if sufficient_student_data?(school:, academic_year:)
    scores << admin_data_averages(school:, academic_year:) if includes_admin_data_items?
    scores
  end

  def teacher_average(school:, academic_year:)
    collect_survey_item_average(survey_items: teacher_survey_items, school:, academic_year:)
  end

  def student_average(school:, academic_year:)
    survey_items = student_survey_items_with_sufficient_responses(school:, academic_year:)
    collect_survey_item_average(survey_items:, school:, academic_year:)
  end

  def admin_data_averages(school:, academic_year:)
    AdminDataValue.where(school:, academic_year:, admin_data_item: admin_data_items).pluck(:likert_score)
  end

  def parent_averages(school:, academic_year:)
    SurveyItemResponse.where(school:, academic_year:,
                             survey_item_id: parent_survey_items).group(:survey_item).average(:likert_score).values
  end
end
