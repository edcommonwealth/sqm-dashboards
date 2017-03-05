require "rails_helper"

RSpec.describe QuestionListsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/question_lists").to route_to("question_lists#index")
    end

    it "routes to #new" do
      expect(:get => "/question_lists/new").to route_to("question_lists#new")
    end

    it "routes to #show" do
      expect(:get => "/question_lists/1").to route_to("question_lists#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/question_lists/1/edit").to route_to("question_lists#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/question_lists").to route_to("question_lists#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/question_lists/1").to route_to("question_lists#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/question_lists/1").to route_to("question_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/question_lists/1").to route_to("question_lists#destroy", :id => "1")
    end

  end
end
