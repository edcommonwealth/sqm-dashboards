require 'rails_helper'

describe DemographicLoader do
  let(:filepath) { 'spec/fixtures/sample_demographics.csv' }

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
    end
  end
end
