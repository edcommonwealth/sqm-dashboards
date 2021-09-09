class DashboardController < ApplicationController

  def index
    @school = School.find_by_slug school_slug
  end

  private

  def school_slug
    params[:school_id]
  end

end