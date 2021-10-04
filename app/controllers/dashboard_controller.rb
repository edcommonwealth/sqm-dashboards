class DashboardController < ApplicationController
  layout "sqm/application"
  before_action :authenticate_district

  def index
    schools
    districts
    @measure_graph_row_presenters = measure_ids
                                      .map { |measure_id| Measure.find_by_measure_id measure_id }
                                      .map(&method(:presenter_for_measure))
                                      .sort
                                      .reverse
  end

  private

  def authenticate_district
    authenticate(district.name.downcase, "#{district.name.downcase}!")
  end

  def measure_ids
    Measure.all.map(&:measure_id)
  end

  def presenter_for_measure(measure)
    score = SurveyItemResponse.for_measure(measure)
                              .where(academic_year: academic_year, school: school)
                              .average(:likert_score)

    MeasureGraphRowPresenter.new(
      measure: measure,
      score: score
    )
  end

  def school
    @school = schools.first if params[:school_id] == "first"
    @school ||= School.find_by_slug school_slug
  end

  def schools
    @schools = School.where(district: district).sort_by(&:name)
  end

  def district
    @district ||= District.find_by_slug district_slug
  end

  def districts
    @districts = District.all.sort_by(&:name)
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
