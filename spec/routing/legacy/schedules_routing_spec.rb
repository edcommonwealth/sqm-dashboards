require "rails_helper"

module Legacy
  RSpec.describe SchedulesController, type: :routing do
    describe "routing" do
      before(:each) do
        @school = School.create!(
          :name => "MyString",
          :district_id => 1
        )
      end

      it "routes to #index" do
        expect(:get => "schools/#{@school.id}/schedules").to route_to("legacy/schedules#index", school_id: @school.id.to_s)
      end

      it "routes to #new" do
        expect(:get => "schools/#{@school.id}/schedules/new").to route_to("legacy/schedules#new", school_id: @school.id.to_s)
      end

      it "routes to #show" do
        expect(:get => "schools/#{@school.id}/schedules/1").to route_to("legacy/schedules#show", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #edit" do
        expect(:get => "schools/#{@school.id}/schedules/1/edit").to route_to("legacy/schedules#edit", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #create" do
        expect(:post => "schools/#{@school.id}/schedules").to route_to("legacy/schedules#create", school_id: @school.id.to_s)
      end

      it "routes to #update via PUT" do
        expect(:put => "schools/#{@school.id}/schedules/1").to route_to("legacy/schedules#update", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "schools/#{@school.id}/schedules/1").to route_to("legacy/schedules#update", school_id: @school.id.to_s, :id => "1")
      end

      it "routes to #destroy" do
        expect(:delete => "schools/#{@school.id}/schedules/1").to route_to("legacy/schedules#destroy", school_id: @school.id.to_s, :id => "1")
      end

    end
  end
end
