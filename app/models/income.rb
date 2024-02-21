class Income < ApplicationRecord
  scope :by_designation, -> { all.map { |income| [income.designation, income] }.to_h }
  scope :by_slug, -> { all.map { |income| [income.slug, income] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]

  def self.to_designation(income)
    case income
    in /Free\s*Lunch|Reduced\s*Lunch|Low\s*Income|Reduced\s*price\s*lunch|true/i
      "Economically Disadvantaged - Y"
    in /Not\s*Eligible|false/i
      "Economically Disadvantaged - N"
    else
      "Unknown"
    end
  end

  LABELS = {
    "Economically Disadvantaged - Y" => "Economically Disadvantaged",
    "Economically Disadvantaged - N" => "Not Economically Disadvantaged",
    "Unknown" => "Unknown"
  }

  def label
    LABELS[designation]
  end
end
