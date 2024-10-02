# frozen_string_literal: true

class MeasurePresenter
  attr_reader :measure, :academic_year, :school, :id, :name, :description

  def initialize(measure:, academic_year:, school:)
    @measure = measure
    @academic_year = academic_year
    @school = school
    @name = measure.name
    @description = measure.description
    @id = measure.measure_id
  end

  def title
    "Measure #{measure_id}"
  end

  def gauge_presenter
    GaugePresenter.new(zones:, score: score.average)
  end

  def data_item_accordion_id
    "data-item-accordion-#{measure_id}"
  end

  def data_item_presenters
    [].tap do |array|
      array << student_survey_presenter if student_survey_items.any?
      array << teacher_survey_presenter if teacher_survey_items.any?
      array << admin_data_presenter if admin_data_items.any?
    end
  end

  def score
    @score ||= @measure.score(school: @school, academic_year: @academic_year)
  end

  private

  def admin_data_items
    measure.admin_data_items
  end

  def student_survey_items
    measure.student_survey_items
  end

  def teacher_survey_items
    measure.teacher_survey_items
  end

  def measure_id
    measure.measure_id
  end

  def student_survey_presenter
    StudentSurveyPresenter.new(measure_id:, survey_items: student_survey_items,
                               has_sufficient_data: score.meets_student_threshold?, school:, academic_year:)
  end

  def teacher_survey_presenter
    TeacherSurveyPresenter.new(measure_id:, survey_items: teacher_survey_items,
                               has_sufficient_data: score.meets_teacher_threshold?, school:, academic_year:)
  end

  def admin_data_presenter
    AdminDataPresenter.new(measure_id:,
                           admin_data_items:, has_sufficient_data: score.meets_admin_data_threshold?, school:, academic_year:)
  end

  def zones
    Zones.new(
      watch_low_benchmark: @measure.watch_low_benchmark,
      growth_low_benchmark: @measure.growth_low_benchmark,
      approval_low_benchmark: @measure.approval_low_benchmark,
      ideal_low_benchmark: @measure.ideal_low_benchmark
    )
  end
end
