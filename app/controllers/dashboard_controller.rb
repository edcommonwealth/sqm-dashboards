class DashboardController < SqmApplicationController

  def index
    @presenters = measure_ids
                    .map { |measure_id| Measure.find_by_measure_id measure_id }
                    .map(&method(:presenter_for_measure))
                    .sort
                    .reverse
  end

  private

  def measure_ids
    Measure.all.map(&:measure_id)
  end

  def presenter_for_measure(measure)
    score = SurveyItemResponse.for_measure(measure)
                              .where(academic_year: academic_year, school: school)
                              .average(:likert_score)

    MeasureGraphRowPresenter.new(
      measure: measure,
      score: score
    )
  end

end
