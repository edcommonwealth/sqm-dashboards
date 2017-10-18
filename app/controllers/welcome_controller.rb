class WelcomeController < ApplicationController

  def index
    @districts = District.all.alphabetic
    @schools = School.all.alphabetic
  end

end
