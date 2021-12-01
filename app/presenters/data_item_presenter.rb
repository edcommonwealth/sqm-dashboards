class DataItemPresenter
  def initialize(measure_id:, has_sufficient_data:)
    @measure_id = measure_id
    @has_sufficient_data = has_sufficient_data
  end

  def data_item_accordion_id
    "data-item-accordion-#{@measure_id}"
  end

  def sufficient_data?
    @has_sufficient_data
  end
end
