require "rails_helper"
require "fileutils"

RSpec.describe CredentialsLoader do
  let(:path) do
    Rails.root.join("spec", "fixtures", "credentials", "credentials.csv")
  end

  context ".load_credentials" do
    before do
      create(:district, name: "Maynard Public Schools")
      create(:district, name: "Springfield Public Schools")
      create(:district, name: "Boston Public Schools")
    end

    it "loads credentials from the CSV file into the database" do
      file = File.open(Rails.root.join("spec", "fixtures", "sample_district_credentials.csv"))
      # Seeder.new.seed_district_credentials(file:)
      expect { CredentialsLoader.load_credentials(file:) }.to change { District.count }.by(0)

      district = District.find_by(name: "Maynard Public Schools")
      expect(district.username).to eq("maynard_admin")
      expect(district.password).to eq("password123")
      expect(district.login_required).to be true

      district = District.find_by(name: "Springfield Public Schools")
      expect(district.username).to eq("springfield_admin")
      expect(district.password).to eq("password456")
      expect(district.login_required).to be false

      district = District.find_by(name: "Boston Public Schools")
      expect(district.username).to eq("boston_admin")
      expect(district.password).to eq("password789")
      expect(district.login_required).to be true
    end
  end
end
