class DashboardController < ApplicationController
  before_action :set_school

  def index
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    @construct_graph_row_presenters = [
      ConstructGraphRowPresenter.new(construct: Construct.find_by_construct_id('1A-i'), score: 4.8)
    ]
  end

  private

  def set_school
    @school = School.find_by_slug school_slug
  end

  def school_slug
    params[:school_id]
  end

  def district
    @district ||= @school.district
  end

end
