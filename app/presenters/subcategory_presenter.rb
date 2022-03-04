class SubcategoryPresenter
  def initialize(subcategory:, academic_year:, school:)
    @subcategory = subcategory
    @academic_year = academic_year
    @school = school
  end

  def id
    @subcategory.subcategory_id
  end

  def name
    @subcategory.name
  end

  def description
    @subcategory.description
  end

  def gauge_presenter
    GaugePresenter.new(zones:, score: average_score)
  end

  def subcategory_card_presenter
    SubcategoryCardPresenter.new(name: @subcategory.name, zones:, score: average_score)
  end

  def average_score
    @average_score ||= @subcategory.score(school: @school, academic_year: @academic_year)
  end

  def student_response_rate
    return 'N / A' if Respondent.where(school: @school, academic_year: @academic_year).count.zero?

    "#{@subcategory.student_response_rate(school: @school, academic_year: @academic_year).rate}%"
  end

  def teacher_response_rate
    return 'N / A' if Respondent.where(school: @school, academic_year: @academic_year).count.zero?

    "#{@subcategory.teacher_response_rate(school: @school, academic_year: @academic_year).rate}%"
  end

  def admin_collection_rate
    rate = [0, admin_data_item_count]
    format_a_non_applicable_rate rate
  end

  def measure_presenters
    @subcategory.measures.sort_by(&:measure_id).map do |measure|
      MeasurePresenter.new(measure:, academic_year: @academic_year, school: @school)
    end
  end

  private

  def admin_data_item_count
    return AdminDataItem.for_measures(@subcategory.measures).count if @school.is_hs

    AdminDataItem.non_hs_items_for_measures(@subcategory.measures).count
  end

  def format_a_non_applicable_rate(rate)
    rate == [0, 0] ? %w[N A] : rate
  end

  def zones
    Zones.new(
      watch_low_benchmark: measures.map(&:watch_low_benchmark).average,
      growth_low_benchmark: measures.map(&:growth_low_benchmark).average,
      approval_low_benchmark: measures.map(&:approval_low_benchmark).average,
      ideal_low_benchmark: measures.map(&:ideal_low_benchmark).average
    )
  end

  def measures
    @measures ||= @subcategory.measures.includes([:admin_data_items]).order(:measure_id)
  end
end
