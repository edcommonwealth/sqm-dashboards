class Sped < ApplicationRecord
  scope :by_designation, -> { all.map { |sped| [sped.designation, sped] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
end
