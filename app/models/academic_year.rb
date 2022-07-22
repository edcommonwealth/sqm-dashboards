# frozen_string_literal: true

class AcademicYear < ActiveRecord::Base
  def self.find_by_date(date)
    year = parse_year_range(date:)
    AcademicYear.find_by_range("#{year.start}-#{year.end.to_s[2, 3]}")
  end

  def formatted_range
    years = range.split('-')
    "#{years.first} – 20#{years.second}"
  end

  def self.parse_year_range(date:)
    year = date.year
    if date.month > 6
      AcademicYearRange.new(year, year + 1)
    else
      AcademicYearRange.new(year - 1, year)
    end
  end
end

AcademicYearRange = Struct.new(:start, :end)
