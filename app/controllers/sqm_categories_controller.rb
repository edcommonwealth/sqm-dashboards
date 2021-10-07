class SqmCategoriesController < SqmApplicationController

  def show
    @category = CategoryPresenter.new(
      category: SqmCategory.find_by_name('Teachers & Leadership'),
      academic_year: academic_year,
      school: school,
    )
  end

end
