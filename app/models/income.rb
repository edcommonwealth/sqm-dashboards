class Income < ApplicationRecord
  scope :by_designation, -> { all.map { |income| [income.designation, income] }.to_h }
  scope :by_slug, -> { all.map { |income| [income.slug, income] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]

  def label
    case designation
    when "Economically Disadvantaged - Y"
      "Economically Disadvantaged"
    when "Economically Disadvantaged - N"
      "Not Economically Disadvantaged"
    when "Unknown"
      "Unknown"
    end
  end
end
