class AdminDataPresenter < DataItemPresenter
  def initialize(measure_id:, admin_data_items:)
    super(measure_id: measure_id, has_sufficient_data: false)
    @admin_data_items = admin_data_items
  end

  def title
    'School admin data'
  end

  def id
    "admin-data-items-#{@measure_id}"
  end

  def item_descriptions
    @admin_data_items.map(&:description)
  end

  def reason_for_insufficiency
    'limited availability'
  end
end
