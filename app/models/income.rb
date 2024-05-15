class Income < ApplicationRecord
  scope :by_designation, -> { all.map { |income| [income.designation, income] }.to_h }
  scope :by_slug, -> { all.map { |income| [income.slug, income] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]

  def self.to_designation(income)
    return "Economically Disadvantaged - N" if income.blank? or income.nil?

    case income
    in /Free\s*Lunch|Reduced\s*Lunch|Low\s*Income|Reduced\s*price\s*lunch|true|1/i
      "Economically Disadvantaged - Y"
    in /Not\s*Eligible|false|0/i
      "Economically Disadvantaged - N"
    in %r{^#*N/*A$|Unknown}i
      "Unknown"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing Income column. '#{income}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
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
