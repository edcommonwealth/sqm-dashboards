class HomeController < ActionController::Base
  def index
    @districts = District.all.order(:name)
    @schools = School.all
  end
end
