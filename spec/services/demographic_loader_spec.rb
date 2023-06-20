require 'rails_helper'

describe DemographicLoader do
  let(:filepath) { 'spec/fixtures/sample_demographics.csv' }
  let(:race_codes) do
    { 'American Indian or Alaskan Native' => 1, 'Asian or Pacific Islander' => 2, 'Black or African American' => 3,
      'Hispanic or Latinx' => 4, 'White or Caucasian' => 5, 'Race/Ethnicity Not Listed' => 99, 'Middle Eastern' => 8, 'Multiracial' => 100 }
  end

  let(:gender_codes) do
    {
      'Female' => 1, 'Male' => 2, 'Non-Binary' => 4, 'Unknown' => 99
    }
  end

  let(:incomes) do
    ['Economically Disadvantaged – N', 'Economically Disadvantaged – Y', 'Unknown']
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
      race_codes.each do |key, value|
        expect(Race.find_by_qualtrics_code(value)).not_to eq nil
        expect(Race.find_by_qualtrics_code(value).designation).to eq key
        expect(Race.find_by_designation(key)).not_to eq nil
        expect(Race.find_by_designation(key).qualtrics_code).to eq value
      end
    end

    it 'loads all gender designations' do
      expect(Gender.all.count).to eq 4

      gender_codes.each do |key, value|
        expect(Gender.find_by_qualtrics_code(value)).not_to eq nil
        expect(Gender.find_by_qualtrics_code(value).designation).to eq key
        expect(Gender.find_by_designation(key)).not_to eq nil
        expect(Gender.find_by_designation(key).qualtrics_code).to eq value
      end
    end

    it 'loads all the income designations' do
      expect(Income.all.count).to eq 3
      incomes.each do |income|
        expect(Income.find_by_designation(income).designation).to eq income
      end
    end
  end
end
