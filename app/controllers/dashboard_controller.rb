class DashboardController < ApplicationController
  def index
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    @construct_graph_row_presenters = Construct.where(construct_id: '1A-i').map do | construct |
      ConstructGraphRowPresenter.new(
        construct: construct,
        score: SurveyResponseAggregator.score(school: school, academic_year: academic_year, construct: construct)
      )
    end
  end

  private

  def school
    @school ||= School.find_by_slug school_slug
  end

  def district
    @district ||= school.district
  end

  def school_slug
    params[:school_id]
  end

  def academic_year
    @academic_year ||= params[:year]
  end

end
