class Ell < ApplicationRecord
  scope :by_designation, -> { all.map { |ell| [ell.designation, ell] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
end
