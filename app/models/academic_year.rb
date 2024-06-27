# frozen_string_literal: true

require "date"

class AcademicYear < ActiveRecord::Base
  include FriendlyId
  friendly_id :range, use: [:slugged]

  scope :by_range, -> { all.map { |academic_year| [academic_year.range, academic_year] }.to_h }
  scope :of_year, ->(range) { all.select { |ay| ay.range.start_with?(range) } }

  def self.range_from_date(date, ranges)
    year = parse_year_range(date:)
    range = ranges.find { |item| item.downcase == "#{year.start}-#{year.end.to_s[2, 3]} #{year.season.downcase}" }
    range ||= ranges.find { |item| item.downcase == "#{year.start}-#{year.end.to_s[2, 3]}" }
    range
  end

  def formatted_range
    years = range.split("-").map(&:split).flatten
    "#{years.first} – 20#{years.second} #{years[2]}".chomp
  end

  def range_without_season
    range.scan(/[\d-]/).join
  end

  private

  def self.parse_year_range(date:)
    year = date.year
    ayr = if date.month > 6
            AcademicYearRange.new(year, year + 1)
          else
            AcademicYearRange.new(year - 1, year)
          end

    ayr.season = if in_fall?(date, ayr)
                   "Fall"
                 else
                   "Spring"
                 end
    ayr
  end

  def self.in_fall?(date, ayr)
    date.between?(Date.parse("#{ayr.start}-7-1"), last_sunday(2, ayr.end) - 1)
  end

  # returns a Date object being the last sunday of the given month/year
  # month: integer between 1 and 12
  def self.last_sunday(month, year)
    # get the last day of the month
    date = Date.new year, month, -1
    # subtract number of days we are ahead of sunday
    date -= date.wday
  end

  private_class_method :in_fall?
  private_class_method :parse_year_range
end

AcademicYearRange = Struct.new(:start, :end, :season)

