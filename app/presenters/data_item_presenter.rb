class DataItemPresenter
  def initialize(measure_id:)
    @measure_id = measure_id
  end

  def data_item_accordion_id
    "data-item-accordion-#{@measure_id}"
  end
end
