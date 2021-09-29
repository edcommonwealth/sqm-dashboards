class DashboardController < ApplicationController
  def index
    schools
    districts
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    @measure_graph_row_presenters = measure_ids
                                      .map { |measure_id| Measure.find_by_measure_id measure_id }
                                      .map(&method(:presenter_for_measure))
                                      .sort().reverse
  end

  private

  def measure_ids
    Measure.all.map {|measure |
      measure.measure_id
    }
  end

  def presenter_for_measure(measure)
    MeasureGraphRowPresenter.new(
      measure: measure,
      score: SurveyResponseAggregator.score(school: school, academic_year: academic_year, measure: measure)
    )
  end

  def school
    @school = schools.first  if params[:school_id] == "first"
    @school ||= School.find_by_slug school_slug
  end

  def schools
    @schools = School.where(district: district).sort_by { | school| school.name } 
  end

  def district
    @district ||= District.find_by_slug district_slug
  end

  def districts
    @districts = District.all.sort_by {|district| district.name}
  end

  def district_slug
    params[:district_id]
  end

  def school_slug
    params[:school_id]
  end

  def academic_year
    @academic_year ||= AcademicYear.find_by_range params[:year]
  end

end
