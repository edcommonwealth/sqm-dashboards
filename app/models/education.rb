class Education < ApplicationRecord
  scope :by_designation, -> { all.map { |education| [education.designation, education] }.to_h }

  def self.to_designation(education)
    return "Unknown" if education.blank? || education.nil?

    case education
    in /^1$/i
      "No formal schooling completed"
    in /^2$/i
      "Some formal schooling"
    in /^3$/i
      "High school diploma or GED"
    in /^4$/i
      "Associates Degree"
    in /^5$/i
      "Bachelors Degree"
    in /^6$/i
      "Masters Degree"
    in /^7$/i
      "Professional Degree"
    in /^8$/i
      "Doctorate Degree"
    in /^99$|^100$/i
      "Unknown"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing Education column. '#{education}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end

  def points
    higher_level_education = ["Associates Degree", "Bachelors Degree", "Masters Degree", "Professional Degree", "Doctorate Degree"]
    if higher_level_education.include?(designation)
      1
    else
      0
    end
  end
end
