class DataItemPresenter
  attr_reader :measure_id, :has_sufficient_data, :school, :academic_year

  def initialize(measure_id:, has_sufficient_data:, school:, academic_year:)
    @measure_id = measure_id
    @has_sufficient_data = has_sufficient_data
    @school = school
    @academic_year = academic_year
  end

  def data_item_accordion_id
    "data-item-accordion-#{@measure_id}"
  end

  def sufficient_data?
    @has_sufficient_data
  end
end
