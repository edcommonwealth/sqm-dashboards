# frozen_string_literal: true

class Measure < ActiveRecord::Base
  belongs_to :subcategory, counter_cache: true
  has_one :category, through: :subcategory
  has_many :scales
  has_many :admin_data_items, through: :scales
  has_many :survey_items, through: :scales
  has_many :survey_item_responses, through: :survey_items

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

  def student_survey_items_by_survey_type(school:, academic_year:)
    survey = Survey.where(school:, academic_year:).first
    return student_survey_items.short_form_items if survey.form == 'short'

    student_survey_items
  end

  def teacher_scales
    @teacher_scales ||= scales.teacher_scales
  end

  def student_scales
    @student_scales ||= scales.student_scales
  end

  def includes_teacher_survey_items?
    @includes_teacher_survey_items ||= teacher_survey_items.any?
  end

  def includes_student_survey_items?
    @includes_student_survey_items ||= student_survey_items.any?
  end

  def includes_admin_data_items?
    @includes_admin_data_items ||= admin_data_items.any?
  end

  # def sources
  #   @sources ||= begin
  #     sources = []
  #     sources << Source.new(name: :admin_data, collection: admin_data_items) if includes_admin_data_items?
  #     sources << Source.new(name: :student_surveys, collection: student_survey_items) if includes_student_survey_items?
  #     sources << Source.new(name: :teacher_surveys, collection: teacher_survey_items) if includes_teacher_survey_items?
  #     sources
  #   end
  # end

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo, (school, academic_year)|
      next Score::NIL_SCORE if incalculable_score(school:, academic_year:)

      scores = collect_averages_for_teacher_student_and_admin_data(school:, academic_year:)
      average = scores.flatten.compact.remove_blanks.average

      next Score::NIL_SCORE if average.nan?

      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @score[[school, academic_year]]
  end

  def student_score(school:, academic_year:)
    @student_score ||= Hash.new do |memo, (school, academic_year)|
      meets_student_threshold = sufficient_student_data?(school:, academic_year:)
      average = student_average(school:, academic_year:) if meets_student_threshold
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @student_score[[school, academic_year]]
  end

  def teacher_score(school:, academic_year:)
    @teacher_score ||= Hash.new do |memo, (school, academic_year)|
      meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
      average = teacher_average(school:, academic_year:) if meets_teacher_threshold
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @teacher_score[[school, academic_year]]
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

  private

  def any_admin_data_collected?(school:, academic_year:)
    @any_admin_data_collected ||= Hash.new do |memo, (school, academic_year)|
      total_collected_admin_data_items =
        admin_data_items.map do |admin_data_item|
          admin_data_item.admin_data_values.where(school:, academic_year:).count
        end.flatten.sum
      memo[[school, academic_year]] = total_collected_admin_data_items.positive?
    end
    @any_admin_data_collected[[school, academic_year]]
  end

  def sufficient_survey_responses?(school:, academic_year:)
    @sufficient_survey_responses ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] =
        sufficient_student_data?(school:, academic_year:) || sufficient_teacher_data?(school:, academic_year:)
    end
    @sufficient_survey_responses[[school, academic_year]]
  end

  def scorify(average:, school:, academic_year:)
    meets_student_threshold = sufficient_student_data?(school:, academic_year:)
    meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
    meets_admin_data_threshold = any_admin_data_collected?(school:, academic_year:)
    Score.new(average, meets_teacher_threshold, meets_student_threshold, meets_admin_data_threshold)
  end

  def collect_survey_item_average(survey_items:, school:, academic_year:)
    @collect_survey_item_average ||= Hash.new do |memo, (survey_items, school, academic_year)|
      averages = survey_items.map do |survey_item|
        grouped_responses(school:, academic_year:)[survey_item]
      end.remove_blanks
      memo[[survey_items, school, academic_year]] = averages.average || 0
    end
    @collect_survey_item_average[[survey_items, school, academic_year]]
  end

  def collect_admin_scale_average(admin_data_items:, school:, academic_year:)
    @collect_admin_scale_average ||= Hash.new do |memo, (admin_data_items, school, academic_year)|
      memo[[admin_data_items, school, academic_year]] = begin
        admin_values = AdminDataValue.where(school:, academic_year:)
        admin_values.map do |admin_value|
          admin_value.likert_score if admin_value.present?
        end
      end
    end
    @collect_admin_scale_average[[admin_data_items, school, academic_year]]
  end

  def grouped_responses(school:, academic_year:)
    @grouped_responses ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] =
        SurveyItemResponse.where(school:, academic_year:).group(:survey_item).average(:likert_score)
    end
    @grouped_responses[[school, academic_year]]
  end

  def benchmark(name)
    averages = []
    averages << student_survey_items.first.send(name) if includes_student_survey_items?
    averages << teacher_survey_items.first.send(name) if includes_teacher_survey_items?
    (averages << admin_data_items.map(&name)).flatten! if includes_admin_data_items?
    averages.average
  end

  def sufficient_student_data?(school:, academic_year:)
    false unless includes_student_survey_items?
    false if no_student_responses_exist?(school:, academic_year:)

    # this gets memoized on first run so check to make sure
    subcategory.response_rate(school:, academic_year:).meets_student_threshold?
  end

  def sufficient_teacher_data?(school:, academic_year:)
    return @sufficient_teacher_data ||= false unless includes_teacher_survey_items?
    return @sufficient_teacher_data ||= false if no_teacher_responses_exist?(school:, academic_year:)

    @sufficient_teacher_data ||= subcategory.response_rate(school:, academic_year:).meets_teacher_threshold?
  end

  def no_student_responses_exist?(school:, academic_year:)
    @no_student_responses_exist ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = student_survey_items_by_survey_type(school:, academic_year:).all? do |survey_item|
        survey_item.survey_item_responses.where(school:, academic_year:).none?
      end
    end
    @no_student_responses_exist[[school, academic_year]]
  end

  def no_teacher_responses_exist?(school:, academic_year:)
    @no_teacher_responses_exist ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = teacher_survey_items.all? do |survey_item|
        survey_item.survey_item_responses.where(school:, academic_year:).none?
      end
    end
    @no_teacher_responses_exist[[school, academic_year]]
  end

  def incalculable_score(school:, academic_year:)
    @incalculable_score ||= Hash.new do |memo, (school, academic_year)|
      lacks_sufficient_survey_data = !sufficient_student_data?(school:, academic_year:) &&
                                     !sufficient_teacher_data?(school:, academic_year:)
      memo[[school, academic_year]] = lacks_sufficient_survey_data && !includes_admin_data_items?
    end

    @incalculable_score[[school, academic_year]]
  end

  def collect_averages_for_teacher_student_and_admin_data(school:, academic_year:)
    scores = []
    scores << teacher_average(school:, academic_year:) if sufficient_teacher_data?(school:, academic_year:)
    scores << student_average(school:, academic_year:) if sufficient_student_data?(school:, academic_year:)
    scores << admin_data_averages(school:, academic_year:) if includes_admin_data_items?
    scores
  end

  def teacher_average(school:, academic_year:)
    @teacher_average ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] =
        collect_survey_item_average(survey_items: teacher_survey_items, school:, academic_year:)
    end

    @teacher_average[[school, academic_year]]
  end

  def student_average(school:, academic_year:)
    @student_average ||= Hash.new do |memo, (school, academic_year)|
      survey_items = student_survey_items_by_survey_type(school:, academic_year:)
      memo[[school, academic_year]] = collect_survey_item_average(survey_items:, school:, academic_year:)
    end
    @student_average[[school, academic_year]]
  end

  def admin_data_averages(school:, academic_year:)
    @admin_data_averages ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = collect_admin_scale_average(admin_data_items:, school:, academic_year:)
    end
    @admin_data_averages[[school, academic_year]]
  end
end
