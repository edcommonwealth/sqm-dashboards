class DashboardController < ApplicationController
  def index
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    @measure_graph_row_presenters = Measure.where(measure_id: '1A-i').map do | measure |
      MeasureGraphRowPresenter.new(
        measure: measure,
        score: SurveyResponseAggregator.score(school: school, academic_year: academic_year, measure: measure)
      )
    end
  end

  private

  def school
    @school ||= School.find_by_slug school_slug
  end

  def district
    @district ||= District.find_by_slug district_slug
  end

  def district_slug
    params[:district_id]
  end

  def school_slug
    params[:school_id]
  end

  def academic_year
    @academic_year ||= params[:year]
  end

end
