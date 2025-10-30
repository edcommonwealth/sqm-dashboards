class Benefit < ApplicationRecord
  scope :by_designation, -> { all.map { |benefits| [benefits.designation, benefits] }.to_h }

  def self.to_designation(benefits)
    return "Unknown" if benefits.blank? || benefits.nil?

    case benefits
    in /^1$/i
      "Yes"
    in /^2$/i
      "No"
    in /^3$/i
      "Unknown"
    in /^99$|^100$/i
      "Unknown"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing benefits column. '#{benefits}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end

  def points
    return 1 if designation == "No"

    0
  end
end
