class HomeController < ActionController::Base
  before_action :set_google_analytics_id

  def index
    @districts = District.all.order(:name)
    @schools = School.all

    @categories = Category.sorted.map { |category| CategoryPresenter.new(category: category) }
  end

  private

  def set_google_analytics_id
    @google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']
  end
end
