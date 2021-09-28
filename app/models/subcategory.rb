class Subcategory < ActiveRecord::Base
  belongs_to :sqm_category

  has_many :measures
end
