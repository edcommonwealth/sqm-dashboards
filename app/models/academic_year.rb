class AcademicYear < ActiveRecord::Base
  def self.find_by_date(date)
    if date.month > 6
      ay_range_start = date.year
      ay_range_end = date.year + 1
    else
      ay_range_start = date.year - 1
      ay_range_end = date.year
    end
    AcademicYear.find_by_range("#{ay_range_start}-#{ay_range_end.to_s[2, 3]}")
  end

  def formatted_range
    years = range.split('-')
    "#{years.first} – 20#{years.second}"
  end

end
