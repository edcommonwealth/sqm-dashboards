require "rails_helper"

module Legacy
  RSpec.describe SchoolsController, type: :routing do
    describe "routing" do

      it "routes to #index" do
        expect(:get => "/schools").to route_to("legacy/schools#index")
      end

      it "routes to #new" do
        expect(:get => "/schools/new").to route_to("legacy/schools#new")
      end

      it "routes to #show" do
        expect(:get => "/schools/1").to route_to("legacy/schools#show", :id => "1")
      end

      it "routes to #edit" do
        expect(:get => "/schools/1/edit").to route_to("legacy/schools#edit", :id => "1")
      end

      it "routes to #create" do
        expect(:post => "/schools").to route_to("legacy/schools#create")
      end

      it "routes to #update via PUT" do
        expect(:put => "/schools/1").to route_to("legacy/schools#update", :id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "/schools/1").to route_to("legacy/schools#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(:delete => "/schools/1").to route_to("legacy/schools#destroy", :id => "1")
      end

    end
  end
end
