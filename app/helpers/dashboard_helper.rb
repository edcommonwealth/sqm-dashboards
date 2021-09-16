module DashboardHelper
  def format_academic_year(ay)
    years = ay.split('-')
    "#{years.first} – 20#{years.second}"
  end
end
