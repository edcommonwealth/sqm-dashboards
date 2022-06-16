class SqmApplicationController < ApplicationController
  protect_from_forgery with: :exception, prepend: true
  before_action :set_schools_and_districts
  helper HeaderHelper

  private

  def set_schools_and_districts
    @district = District.find_by_slug district_slug
    @districts = District.all.order(:name).load_async
    @school = School.find_by_slug(school_slug)
    @schools = School.includes([:district]).where(district: @district).order(:name).load_async
    @academic_year = AcademicYear.find_by_range params[:year]
    @academic_years = AcademicYear.all.order(range: :desc).load_async
  end

  def district_slug
    params[:district_id]
  end

  def school_slug
    params[:school_id]
  end
end
