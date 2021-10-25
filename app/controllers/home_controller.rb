class HomeController < ActionController::Base
  def index
    @districts = District.all.order(:name)
    @schools = School.all

    @categories = SqmCategory.all.order(:sort_index).map { |category| CategoryPresenter.new(category: category) }
  end
end
