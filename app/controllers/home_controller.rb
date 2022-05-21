class HomeController < ApplicationController
  helper HeaderHelper
  def index
    @districts = District.all.order(:name)
    @schools = School.all.includes([:district]).order(:name)

    @categories = Category.sorted.map { |category| CategoryPresenter.new(category:) }
  end
end
