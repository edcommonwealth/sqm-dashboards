class SqmCategory < ActiveRecord::Base
  include FriendlyId
  friendly_id :name, use: [:slugged]

  scope :sorted, ->() { order(:sort_index) }

  has_many :subcategories
end
