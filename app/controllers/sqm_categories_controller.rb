class SqmCategoriesController < SqmApplicationController

  def show
    @categories = SqmCategory.all.order(:sort_index).map { |category| CategoryPresenter.new(category: category) }

    @category = CategoryPresenter.new(category: SqmCategory.find_by_slug(params[:id]))
  end

end
