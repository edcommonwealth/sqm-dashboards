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
    return survey_items.student_survey_items.short_form_items if survey.form == 'short'

    survey_items.student_survey_items
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

  def sources
    @sources ||= begin
      sources = []
      sources << :admin_data if includes_admin_data_items?
      sources << :student_surveys if includes_student_survey_items?
      sources << :teacher_surveys if includes_teacher_survey_items?
      sources
    end
  end

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo, (school, academic_year)|
      meets_student_threshold = sufficient_student_data?(school:, academic_year:)
      meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
      meets_admin_data_threshold = any_admin_data_collected?(school:, academic_year:)
      lacks_sufficient_survey_data = !meets_student_threshold && !meets_teacher_threshold
      incalculable_score = lacks_sufficient_survey_data && !includes_admin_data_items?

      next Score.new(nil, false, false, false) if incalculable_score

      scores = []
      if meets_teacher_threshold
        scores << collect_survey_item_average(survey_items: teacher_survey_items, school:,
                                              academic_year:)
      end
      if meets_student_threshold
        scores << collect_survey_item_average(survey_items: student_survey_items_by_survey_type(school:, academic_year:), school:,
                                              academic_year:)
      end
      scores << collect_admin_scale_average(admin_data_items:, school:, academic_year:) if includes_admin_data_items?

      average = scores.flatten.compact.remove_blanks.average

      next Score.new(nil, false, false, false) if average.nan?

      memo[[school, academic_year]] =
        Score.new(average, meets_teacher_threshold, meets_student_threshold, meets_admin_data_threshold)
    end

    @score[[school, academic_year]]
  end

  def student_score(school:, academic_year:)
    @student_score ||= Hash.new do |memo, (school, academic_year)|
      meets_student_threshold = sufficient_student_data?(school:, academic_year:)
      if meets_student_threshold
        average = collect_survey_item_average(survey_items: student_survey_items_by_survey_type(school:, academic_year:), school:,
                                              academic_year:)
      end
      memo[[school, academic_year]] = scorify(average:, school:, academic_year:)
    end

    @student_score[[school, academic_year]]
  end

  def teacher_score(school:, academic_year:)
    @teacher_score ||= Hash.new do |memo, (school, academic_year)|
      meets_teacher_threshold = sufficient_teacher_data?(school:, academic_year:)
      if meets_teacher_threshold
        average = collect_survey_item_average(survey_items: teacher_survey_items, school:,
                                              academic_year:)
      end
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
      total_collected_admin_data_items = scales.map do |scale|
        scale.admin_data_items.map do |admin_data_item|
          admin_data_item.admin_data_values.where(school:, academic_year:).count
        end
      end.flatten.sum
      memo[[school, academic_year]] = total_collected_admin_data_items > 0
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
        grouped_responses(school:, academic_year:)[survey_item] || 0
      end.remove_blanks
      memo[[survey_items, school, academic_year]] = averages.any? ? averages.average : 0
    end
    @collect_survey_item_average[[survey_items, school, academic_year]]
  end

  def collect_admin_scale_average(admin_data_items:, school:, academic_year:)
    @collect_admin_scale_average ||= Hash.new do |memo, (admin_data_items, school, academic_year)|
      memo[[admin_data_items, school, academic_year]] = admin_data_items.map do |admin_data_item|
        admin_value = admin_data_item.admin_data_values.where(school:, academic_year:).first
        admin_value.likert_score if admin_value.present?
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
    return @sufficient_student_data ||= false unless includes_student_survey_items?
    return @sufficient_student_data ||= false if student_survey_items_by_survey_type(school:,
                                                                                     academic_year:).all? do |survey_item|
                                                   survey_item.survey_item_responses.where(school:,
                                                                                           academic_year:).none?
                                                 end

    @sufficient_student_data ||= subcategory.response_rate(school:, academic_year:).meets_student_threshold?
  end

  def sufficient_teacher_data?(school:, academic_year:)
    return @sufficient_teacher_data ||= false unless includes_teacher_survey_items?
    return @sufficient_teacher_data ||= false if teacher_survey_items.all? do |survey_item|
                                                   survey_item.survey_item_responses.where(school:,
                                                                                           academic_year:).none?
                                                 end

    @sufficient_teacher_data ||= subcategory.response_rate(school:, academic_year:).meets_teacher_threshold?
  end
end
