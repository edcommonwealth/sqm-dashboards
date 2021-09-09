class DashboardController < ApplicationController
  before_action :set_school

  def index
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    @construct_graph_row_presenters = [
      ConstructGraphRowPresenter.new(construct: professional_qualifications_construct, score: 4.8)
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

  def professional_qualifications_construct
    Construct.new title: "Professional Qualifications", watch_low_benchmark: 2.48, growth_low_benchmark: 2.99, approval_low_benchmark: 3.49, ideal_low_benchmark: 4.7
  end

end
