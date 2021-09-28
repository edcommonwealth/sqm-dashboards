class Measure < ActiveRecord::Base
  belongs_to :subcategory
  has_many :survey_items

  has_many :survey_item_responses, through: :survey_items
end
