class Income < ApplicationRecord
  scope :by_designation, -> { all.map { |income| [income.designation, income] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
end
