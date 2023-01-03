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

  def self.academic_years
    @@academic_years ||= AcademicYear.all.map { |academic_year| [academic_year.range, academic_year] }.to_h
  end

  private_class_method :academic_years
  private_class_method :parse_year_range
end

AcademicYearRange = Struct.new(:start, :end)
