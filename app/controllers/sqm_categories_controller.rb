class SqmCategoriesController < SqmApplicationController

  def show
    @categories = SqmCategory.sorted.map { |category| CategoryPresenter.new(category: category) }

    @category = CategoryPresenter.new(category: SqmCategory.find_by_slug(params[:id]))
  end

end
