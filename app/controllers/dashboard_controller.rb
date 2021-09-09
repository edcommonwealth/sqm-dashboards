class DashboardController < ApplicationController
  before_action :set_school

  def index
    authenticate(district.name.downcase, "#{district.name.downcase}!")
  end

  private

  def set_school
    @school = School.find_by_slug school_slug
  end

  def school_slug
    params[:school_id]
  end

  def district
    @school.district
  end

end