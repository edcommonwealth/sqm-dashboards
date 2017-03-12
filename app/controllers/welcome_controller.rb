class WelcomeController < ApplicationController

  def index
    @districts = District.all
    @schools = School.all
  end

end
