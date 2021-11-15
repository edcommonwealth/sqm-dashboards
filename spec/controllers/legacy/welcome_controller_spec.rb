require 'rails_helper'

module Legacy
  RSpec.describe WelcomeController, type: :controller do

    describe "GET #index" do
      it "works" do
        get :index
      end
    end

  end
end
