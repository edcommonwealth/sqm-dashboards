class SubcategoryPresenter
  def initialize(subcategory:, academic_year:, school:)
    @subcategory = subcategory
    @academic_year = academic_year
    @school = school
  end

  def name
    @subcategory.name
  end

  def description
    @subcategory.description
  end

  def gauge_presenter
    GaugePresenter.new(scale: scale, score: average_score)
  end

  def subcategory_card_presenter
    SubcategoryCardPresenter.new(name: @subcategory.name, scale: scale, score: average_score)
  end

  def average_score
    @average_score ||= SurveyItemResponse.score_for_subcategory(subcategory: @subcategory, school: @school, academic_year: @academic_year)
  end

  def measure_presenters
    measures.map { |measure| MeasurePresenter.new(measure: measure, academic_year: @academic_year, school: @school) }
  end

  private

  def scale
    Scale.new(
      watch_low_benchmark: measures.map(&:watch_low_benchmark).average,
      growth_low_benchmark: measures.map(&:growth_low_benchmark).average,
      approval_low_benchmark: measures.map(&:approval_low_benchmark).average,
      ideal_low_benchmark: measures.map(&:ideal_low_benchmark).average,
    )
  end

  def measures
    @measures ||= @subcategory.measures
  end
end

