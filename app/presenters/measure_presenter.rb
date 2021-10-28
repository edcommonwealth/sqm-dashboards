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
