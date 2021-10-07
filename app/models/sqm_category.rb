class SqmCategory < ActiveRecord::Base
  include FriendlyId

  friendly_id :name, use: [:slugged]

  has_many :subcategories
end
