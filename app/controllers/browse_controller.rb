class BrowseController < ApplicationController
  def show
    @category = CategoryPresenter.new(
      category: SqmCategory.find_by_name('Teachers & Leadership'),
      academic_year: academic_year,
      school: school,
    )
  end

  private

  def school
    @school ||= School.find_by_slug school_slug
  end

  def school_slug
    params[:school_id]
  end

  def academic_year
    @academic_year ||= AcademicYear.find_by_range params[:year]
  end
end
