class SqmApplicationController < ApplicationController
  protect_from_forgery with: :exception, prepend: true
  before_action :set_schools_and_districts

  private

  def authenticate_district
    authenticate(@district.name.downcase, "#{@district.name.downcase}!")
  end

  def set_schools_and_districts
    @district = District.find_by_slug district_slug
    @districts = District.all.order(:name)
    @school = School.find_by_slug(school_slug)
    @schools = School.includes([:district]).where(district: @district).order(:name)
    @academic_year = AcademicYear.find_by_range params[:year]
    @academic_years = AcademicYear.all.order(range: :desc)
    @has_empty_dataset = Measure.all.all? do |measure|
      measure.none_meet_threshold? school: @school, academic_year: @academic_year
    end
  end

  def district_slug
    params[:district_id]
  end

  def school_slug
    params[:school_id]
  end
end
