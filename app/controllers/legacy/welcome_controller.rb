module Legacy
  class WelcomeController < ApplicationController

    def index
      @districts = Legacy::District.all.alphabetic
      @schools = Legacy::School.all.alphabetic
    end

  end
end
