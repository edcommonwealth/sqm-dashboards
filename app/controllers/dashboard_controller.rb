class DashboardController < SqmApplicationController

  def index
    @measure_graph_row_presenters = measure_ids
                                      .map { |measure_id| Measure.find_by_measure_id measure_id }
                                      .map(&method(:presenter_for_measure))
                                      .sort
                                      .reverse

    @category_presenters = SqmCategory.all.map { |sqm_category| CategoryPresenter.new(category: sqm_category) }
  end

  private

  def measure_ids
    Measure.all.map(&:measure_id)
  end

  def presenter_for_measure(measure)
    score = SurveyItemResponse.score_for_measure(measure: measure, school: @school, academic_year: @academic_year)

    MeasureGraphRowPresenter.new(measure: measure, score: score)
  end
end
