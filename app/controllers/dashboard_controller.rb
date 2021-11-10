class DashboardController < SqmApplicationController

  def index
    @variance_chart_row_presenters = Measure.all.map(&method(:presenter_for_measure))
    @category_presenters = SqmCategory.sorted.map { |sqm_category| CategoryPresenter.new(category: sqm_category) }
  end

  private

  def presenter_for_measure(measure)
    score = SurveyItemResponse.score_for_measure(measure: measure, school: @school, academic_year: @academic_year)

    VarianceChartRowPresenter.new(measure: measure, score: score)
  end
end
