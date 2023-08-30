require "rails_helper"
require "fileutils"

RSpec.describe DisaggregationLoader do
  let(:path) do
    Rails.root.join("spec", "fixtures", "disaggregation")
  end
  let(:academic_year) { create(:academic_year, range: "2022-23") }
  let(:district) { create(:district, name: "Maynard Public Schools") }
  context ".load" do
    it "loads data from the file into a hash" do
      data = DisaggregationLoader.new(path:).load
      expect(data.values.first.lasid).to eq("1")
      expect(data.values.first.academic_year).to eq("2022-23")
      expect(data.values.first.district).to eq("Maynard Public Schools")

      expect(data.values.last.lasid).to eq("500")
      expect(data.values.last.academic_year).to eq("2022-23")
      expect(data.values.last.district).to eq("Maynard Public Schools")
    end

    it "loads income data" do
      data = DisaggregationLoader.new(path:).load
      expect(data.values.first.raw_income).to eq("Free Lunch")
      expect(data.values.last.raw_income).to eq("Not Eligible")

      expect(data[["1", "Maynard Public Schools", "2022-23"]].raw_income).to eq("Free Lunch")
      expect(data[["2", "Maynard Public Schools", "2022-23"]].raw_income).to eq("Not Eligible")
      expect(data[["3", "Maynard Public Schools", "2022-23"]].raw_income).to eq("Reduced Lunch")
    end
  end

  context "Creating a new loader" do
    it "creates a directory for the loader file" do
      DisaggregationLoader.new(path:)
      expect(path).to exist
    end
  end
end

