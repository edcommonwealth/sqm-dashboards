require 'rails_helper'
include Analyze::Graph
include Analyze::Graph::Column

describe StudentsByRace do
  let(:american_indian) { create(:race, designation: "american indian", qualtrics_code: 1) }
  let(:asian) { create(:race, designation: "asian", qualtrics_code: 2) }
  let(:black) { create(:race, designation: "black", qualtrics_code: 3) }
  let(:hispanic) { create(:race, designation: "hispanic", qualtrics_code: 4) }
  let(:white) { create(:race, designation: "white", qualtrics_code: 5) }
  let(:unknown) { create(:race, designation: "unknown", qualtrics_code: 99) }
  let(:multiracial) { create(:race, designation: "multiracial", qualtrics_code: 100) }
  context 'when initialized with a list of races' do
    it 'generates corresponding race columns' do
      races = [american_indian]
      expect(StudentsByRace.new(races:).columns.map(&:label).map { |words| words.join(" ") }).to eq ["american indian", "All Students"]
      races = [american_indian, asian]
      expect(StudentsByRace.new(races:).columns.map(&:label).map { |words| words.join(" ") }).to eq ["american indian", "asian", "All Students"]
      races = [black, hispanic, multiracial]
      expect(StudentsByRace.new(races:).columns.map(&:label).map { |words| words.join(" ") }).to eq ["black", "hispanic", "multiracial", "All Students"]
    end
  end
end
