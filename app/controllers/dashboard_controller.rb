class DashboardController < SqmApplicationController

  def index
    @measure_graph_row_presenters = measure_ids
                                      .map { |measure_id| Measure.find_by_measure_id measure_id }
                                      .map(&method(:presenter_for_measure))
                                      .sort
                                      .reverse

    @category_presenters = SqmCategory.all.map { |sqm_category| CategoryPresenter.new(
      category: sqm_category,
      academic_year: academic_year,
      school: school,
    )}

  end


  private

  def measure_ids
    Measure.all.map(&:measure_id)
  end

  def presenter_for_measure(measure)
    sufficient_data = SurveyItemResponse.sufficient_data?(measure: measure, academic_year: academic_year, school: school)

    unless sufficient_data
      return MeasureGraphRowPresenter.new(
        measure: measure,
        sufficient_data: false
      )
    end

    score = SurveyItemResponse.for_measure(measure)
                              .where(academic_year: academic_year, school: school)
                              .average(:likert_score)

    MeasureGraphRowPresenter.new(
      measure: measure,
      score: score
    )
  end

end
