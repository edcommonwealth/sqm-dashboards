class Sped < ApplicationRecord
  scope :by_designation, -> { all.map { |sped| [sped.designation, sped] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(sped)
    case sped
    in /active/i
      "Special Education"
    in /^NA$|^#NA$/i
      "Unknown"
    else
      "Not Special Education"
    end
  end
end
