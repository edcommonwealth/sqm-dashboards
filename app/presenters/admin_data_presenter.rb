# frozen_string_literal: true

class AdminDataPresenter < DataItemPresenter
  def initialize(measure_id:, admin_data_items:, has_sufficient_data:, school:, academic_year:)
    super(measure_id:, has_sufficient_data:, school:, academic_year:)
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

  def descriptions_and_availability
    @admin_data_items.map do |admin_data_item|
      DataAvailability.new(admin_data_item.admin_data_item_id, admin_data_item.description,
                           admin_data_item.admin_data_values.where(school:, academic_year:).count > 0)
    end
  end
end
