class SqmApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  layout "sqm/application"
  before_action :authenticate_district
  before_action :set_schools_and_districts

  private

  attr_reader :academic_year

  def authenticate_district
    authenticate(district.name.downcase, "#{district.name.downcase}!")
  end

  def set_schools_and_districts
    @schools = School.where(district: district).sort_by(&:name)
    @districts = District.all.sort_by(&:name)
    @academic_year ||= AcademicYear.find_by_range params[:year]
  end

  def district
    @district ||= District.find_by_slug district_slug
  end

  def school
    @school ||= School.find_by_slug school_slug
  end

  def district_slug
    params[:district_id]
  end

  def school_slug
    params[:school_id]
  end

  def authenticate(username, password)
    return true if username == "boston"
    authenticate_or_request_with_http_basic do |u, p|
      u == username && p == password
    end
  end

end
