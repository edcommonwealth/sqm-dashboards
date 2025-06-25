class Employment < ApplicationRecord
  scope :by_designation, -> { all.map { |employment| [employment.designation, employment] }.to_h }

  def self.to_designation(employment)
    return "Unknown" if employment.blank? or employment.nil?

    case employment
    in /^1$/i
      "Two adults with full-time employment"
    in /^2$/i
      "One adult with full-time employment"
    in /^3$/i
      "Two adults with part-time employment"
    in /^4$/i
      "One adult with part-time employment"
    in /^5$/i
      "No full-time or part-time employment"
    in /^99$|^100$/i
      "Unknown"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing Income column. '#{employment}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end

  def points
    higher_level_employment = ["Two adults with full-time employment", "One adult with full-time employment"]
    if higher_level_employment.include?(designation)
      1
    else
      0
    end
  end
end
