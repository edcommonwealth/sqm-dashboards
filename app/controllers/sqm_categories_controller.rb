class SqmCategoriesController < SqmApplicationController

  def show
    @categories = SqmCategory.all.order(:sort_index).map do |category|
      CategoryPresenter.new(
        category: category,
        academic_year: academic_year,
        school: school,
      )
    end

    @category = CategoryPresenter.new(
      category: SqmCategory.find_by_slug(params[:id]),
      academic_year: academic_year,
      school: school,
    )
  end

end
