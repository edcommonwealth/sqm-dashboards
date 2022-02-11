class AdminDataItem < ActiveRecord::Base
  belongs_to :measure

  scope :for_measures, ->(measure) {
    joins(:measure).where('admin_data_items.measure': measure)
  }

  scope :non_hs_items_for_measures, ->(measure) {
    for_measures(measure).where(hs_only_item: false)
  }
end
