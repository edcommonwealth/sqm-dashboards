class HomeController < ActionController::Base
  def index
    @districts = District.all.order(:name)
    @schools = School.all

    @categories = Category.sorted.map { |category| CategoryPresenter.new(category: category) }
  end
end
