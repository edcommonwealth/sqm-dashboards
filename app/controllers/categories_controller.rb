# frozen_string_literal: true

class CategoriesController < SqmApplicationController
  helper GaugeHelper

  def show
    @categories = Category.sorted.map { |category| CategoryPresenter.new(category:) }

    @category = CategoryPresenter.new(category: Category.find_by_slug(params[:id]))
  end
end
