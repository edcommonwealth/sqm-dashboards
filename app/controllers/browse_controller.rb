class BrowseController < ApplicationController
  layout "sqm/application"
  before_action :authenticate_district

  def show
    @category = CategoryPresenter.new(
      category: SqmCategory.find_by_name('Teachers & Leadership'),
      academic_year: academic_year,
      school: school,
    )
  end

  private

  def authenticate_district
    authenticate(district.name.downcase, "#{district.name.downcase}!")
  end

  def district
    @district ||= District.find_by_slug district_slug
  end

  def school
    @school ||= School.find_by_slug school_slug
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
