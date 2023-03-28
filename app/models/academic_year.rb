# frozen_string_literal: true

class AcademicYear < ActiveRecord::Base
  def self.find_by_date(date)
    year = parse_year_range(date:)
    range = "#{year.start}-#{year.end.to_s[2, 3]}"
    academic_years[range]
  end

  def formatted_range
    years = range.split('-')
    "#{years.first} – 20#{years.second}"
  end

  private

  def self.parse_year_range(date:)
    year = date.year
    if date.month > 6
      AcademicYearRange.new(year, year + 1)
    else
      AcademicYearRange.new(year - 1, year)
    end
  end

  # This may cause problems if academic years get loaded from csv instead of the current method that requires a code change to the seeder script.  This is because a change in code will trigger a complete reload of the application whereas loading from csv does not.  This means if we change academic year to load from csv, the set of academic years will be stale when new years are added.
  def self.academic_years
    @@academic_years ||= AcademicYear.all.map { |academic_year| [academic_year.range, academic_year] }.to_h
  end

  # Needed to reset the academic years when testing with specs that create the same academic year in a before :each block
  def self.reset_academic_years
    @@academic_years = nil
  end

  private_class_method :academic_years
  private_class_method :parse_year_range
end

AcademicYearRange = Struct.new(:start, :end)
