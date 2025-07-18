# frozen_string_literal: true

class SqmApplicationController < ApplicationController
  protect_from_forgery with: :exception, prepend: true
  before_action :set_schools_and_districts
  before_action :authenticate_district

  helper HeaderHelper

  private

  def authenticate_district
    authenticate(@district.username, @district.password)
  end

  def district_name
    @district_name ||= @district.name.split(' ').first.downcase
  end

  def set_schools_and_districts
    @district = District.find_by_slug district_slug
    @districts = District.all.order(:name)
    @school = School.find_by_slug(school_slug)
    @schools = School.includes([:district]).where(district: @district).order(:name)
    @academic_year = AcademicYear.find_by_range params[:year] || AcademicYear.last
    @academic_years = AcademicYear.all.order(range: :desc) || [AcademicYear.last]
  end

  def district_slug
    params[:district_id]
  end

  def school_slug
    params[:school_id]
  end

  def authenticate(username, password)
    return unless @district.login_required

    authenticate_or_request_with_http_basic do |u, p|
      u == username && p == password
    end
  end
end
