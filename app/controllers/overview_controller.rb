class OverviewController < SqmApplicationController

  def index
    @variance_chart_row_presenters = Measure.all.map(&method(:presenter_for_measure))
    @category_presenters = Category.sorted.map { |category| CategoryPresenter.new(category: category) }
  end

  private

  def presenter_for_measure(measure)
    score = SurveyItemResponse.score_for_measure(measure: measure, school: @school, academic_year: @academic_year)

    VarianceChartRowPresenter.new(measure: measure, score: score)
  end
end