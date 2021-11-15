class Subcategory < ActiveRecord::Base
  belongs_to :category

  has_many :measures
end
