class AdminDataItem < ActiveRecord::Base
  belongs_to :scale
  has_many :admin_data_values

  scope :for_measures, lambda { |measures|
    joins(:scale).where('scale.measure': measures)
  }

  scope :non_hs_items_for_measures, lambda { |measure|
    for_measures(measure).where(hs_only_item: false)
  }
end
