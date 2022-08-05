require 'rails_helper'
include Analyze::Graph
include Analyze::Graph::Column
describe StudentsByGroup do
  let(:american_indian) { create(:race, qualtrics_code: 1) }
  let(:asian) { create(:race, qualtrics_code: 2) }
  let(:black) { create(:race, qualtrics_code: 3) }
  let(:hispanic) { create(:race, qualtrics_code: 4) }
  let(:white) { create(:race, qualtrics_code: 5) }
  let(:unknown) { create(:race, qualtrics_code: 99) }
  let(:multiracial) { create(:race, qualtrics_code: 100) }
  context 'when initialized with a list of races' do
    it 'generates corresponding race columns' do
      races = [american_indian]
      expect(StudentsByGroup.new(races:).columns).to eq [AmericanIndian, AllStudent]
      races = [american_indian, asian]
      expect(StudentsByGroup.new(races:).columns).to eq [AmericanIndian, Asian, AllStudent]
      races = [black, hispanic, multiracial]
      expect(StudentsByGroup.new(races:).columns).to eq [Black, Hispanic, Multiracial, AllStudent]
    end
  end
end
