require "rails_helper"

RSpec.describe RecipientListsController, type: :routing do
  describe "routing" do
    before(:each) do
      @school = School.create!(
        :name => "MyString",
        :district_id => 1
      )
    end

    it "routes to #index" do
      expect(:get => "schools/#{@school.id}/recipient_lists").to route_to("recipient_lists#index", school_id: @school.id.to_s)
    end

    it "routes to #new" do
      expect(:get => "schools/#{@school.id}/recipient_lists/new").to route_to("recipient_lists#new", school_id: @school.id.to_s)
    end

    it "routes to #show" do
      expect(:get => "schools/#{@school.id}/recipient_lists/1").to route_to("recipient_lists#show", school_id: @school.id.to_s, :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "schools/#{@school.id}/recipient_lists/1/edit").to route_to("recipient_lists#edit", school_id: @school.id.to_s, :id => "1")
    end

    it "routes to #create" do
      expect(:post => "schools/#{@school.id}/recipient_lists").to route_to("recipient_lists#create", school_id: @school.id.to_s)
    end

    it "routes to #update via PUT" do
      expect(:put => "schools/#{@school.id}/recipient_lists/1").to route_to("recipient_lists#update", school_id: @school.id.to_s, :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "schools/#{@school.id}/recipient_lists/1").to route_to("recipient_lists#update", school_id: @school.id.to_s, :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "schools/#{@school.id}/recipient_lists/1").to route_to("recipient_lists#destroy", school_id: @school.id.to_s, :id => "1")
    end

  end
end
