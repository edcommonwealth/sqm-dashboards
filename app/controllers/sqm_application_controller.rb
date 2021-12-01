class SqmApplicationController < ApplicationController
  protect_from_forgery with: :exception, prepend: true
  before_action :set_schools_and_districts
  before_action :authenticate_district

  private

  def authenticate_district
    authenticate(@district.name.downcase, "#{@district.name.downcase}!")
  end

  def set_schools_and_districts
    @district = District.find_by_slug district_slug
    @districts = District.all.sort_by(&:name)
    @school = School.find_by_slug school_slug
    @schools = School.where(district: @district).sort_by(&:name)
    @academic_year = AcademicYear.find_by_range params[:year]
    @has_empty_dataset = Measure.none_meet_threshold? school: @school, academic_year: @academic_year
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
