module DashboardHelper
  def format_academic_year(ay)
    years = ay.range.split('-')
    "#{years.first} – 20#{years.second}"
  end
end
