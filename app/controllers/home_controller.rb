class HomeController < ActionController::Base
  before_action :set_google_analytics_id
  before_action :set_hotjar_id

  def index
    @districts = District.all.order(:name)
    @schools = School.all

    @categories = Category.sorted.map { |category| CategoryPresenter.new(category: category) }
  end

  private

  def set_google_analytics_id
    @google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']
  end

  def set_hotjar_id
    @hotjar_id = ENV['HOTJAR_ID']
  end
end
