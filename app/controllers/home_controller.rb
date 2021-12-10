class HomeController < ApplicationController
  def index
    @districts = District.all.order(:name)
    @schools = School.all.order(:name)

    @categories = Category.sorted.map { |category| CategoryPresenter.new(category: category) }
  end
end
