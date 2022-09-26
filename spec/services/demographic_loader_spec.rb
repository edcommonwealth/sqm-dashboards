require 'rails_helper'

describe DemographicLoader do
  let(:filepath) { 'spec/fixtures/sample_demographics.csv' }
  let(:codes) do
    { 'American Indian or Alaskan Native' => 1, 'Asian or Pacific Islander' => 2, 'Black or African American' => 3,
      'Hispanic or Latinx' => 4, 'White or Caucasian' => 5, 'Unknown' => 99, 'Middle Eastern' => 8, 'Multiracial' => 100 }
  end

  before :each do
    DemographicLoader.load_data(filepath:)
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe 'self.load_data' do
    it 'does not load qualtrics categories for `prefer not to disclose` or `prefer to self-describe`' do
      expect(Race.find_by_qualtrics_code(6)).to be nil
    end
    it 'loads all racial designations' do
      expect(Race.all.count).to eq 8
      codes.each do |key, value|
        expect(Race.find_by_qualtrics_code(value)).not_to be nil
        expect(Race.find_by_qualtrics_code(value).designation).to eq key
        expect(Race.find_by_designation(key)).not_to be nil
        expect(Race.find_by_designation(key).qualtrics_code).to be value
      end
    end
  end
end
