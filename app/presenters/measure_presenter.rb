class MeasurePresenter
  def initialize(measure:, academic_year:, school:)
    @measure = measure
    @academic_year = academic_year
    @school = school
  end

  def name
    @measure.name
  end

  def description
    @measure.description
  end

  def gauge_presenter
    average_score = SurveyItemResponse.score_for_measure(measure: @measure, academic_year: @academic_year, school: @school)
    GaugePresenter.new(scale: scale, score: average_score)
  end

  def data_item_accordion_id
    "data-item-accordion-#{@measure.measure_id}"
  end

  def data_item_presenters
    output = Array.new
    output << StudentSurveyPresenter.new(measure_id: @measure.measure_id, survey_items: @measure.student_survey_items) if @measure.student_survey_items.any?
    output << TeacherSurveyPresenter.new(measure_id: @measure.measure_id, survey_items: @measure.teacher_survey_items) if @measure.teacher_survey_items.any?
    output << AdminDataPresenter.new(measure_id: @measure.measure_id, admin_data_items: @measure.admin_data_items) if @measure.admin_data_items.any?
    output
  end

  private

  def scale
    Scale.new(
      watch_low_benchmark: @measure.watch_low_benchmark,
      growth_low_benchmark: @measure.growth_low_benchmark,
      approval_low_benchmark: @measure.approval_low_benchmark,
      ideal_low_benchmark: @measure.ideal_low_benchmark,
    )
  end
end
