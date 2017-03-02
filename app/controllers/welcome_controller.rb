class WelcomeController < ApplicationController

  def index
    @schools = School.all
  end

end
