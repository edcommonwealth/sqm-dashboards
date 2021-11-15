require "rails_helper"

module Legacy
  RSpec.describe RecipientsController, type: :routing do
    describe "routing" do
      before(:each) do
        @school = School.create!(
          :name => "MyString",
          :district_id => 1
        )
      end

      it "routes to #index" do
        expect(:get => "schools/#{@school.id}/recipients").to route_to("legacy/recipients#index", school_id: @school.id.to_s)
      end

      it "routes to #new" do
        expect(:get => "schools/#{@school.id}/recipients/new").to route_to("legacy/recipients#new", school_id: @school.id.to_s)
      end

      it "routes to #show" do
        expect(:get => "schools/#{@school.id}/recipients/1").to route_to("legacy/recipients#show", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #edit" do
        expect(:get => "schools/#{@school.id}/recipients/1/edit").to route_to("legacy/recipients#edit", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #create" do
        expect(:post => "schools/#{@school.id}/recipients").to route_to("legacy/recipients#create", school_id: @school.id.to_s)
      end

      it "routes to #update via PUT" do
        expect(:put => "schools/#{@school.id}/recipients/1").to route_to("legacy/recipients#update", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "schools/#{@school.id}/recipients/1").to route_to("legacy/recipients#update", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #destroy" do
        expect(:delete => "schools/#{@school.id}/recipients/1").to route_to("legacy/recipients#destroy", school_id: @school.id.to_s, :id => "1")
      end

    end
  end
end
