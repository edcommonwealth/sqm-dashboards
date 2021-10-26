class HomeController < ActionController::Base
  def index
    @districts = District.all.order(:name)
    @schools = School.all

    @categories = SqmCategory.sorted.map { |category| CategoryPresenter.new(category: category) }
  end
end
