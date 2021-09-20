require 'rails_helper'

describe Measure, type: :model do
  it('has all the measures') do
    expect(Measure.count).to eq 30
  end

  it 'returns the measure for the given measure id' do
    measure = Measure.find_by_measure_id('1A-i')

    expect(measure.name).to eq 'Professional Qualifications'
    expect(measure.warning_zone).to eq Measure::Zone.new(1.0, 2.49, :warning)
    expect(measure.watch_zone).to eq Measure::Zone.new(2.49, 3.0, :watch)
    expect(measure.growth_zone).to eq Measure::Zone.new(3.0, 3.5, :growth)
    expect(measure.approval_zone).to eq Measure::Zone.new(3.5, 4.71, :approval)
    expect(measure.ideal_zone).to eq Measure::Zone.new(4.71, 5.0, :ideal)
  end

  describe '#zone_for_score' do
    let(:measure) {
      Measure.new watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5
    }

    context 'when the score is 1.0' do
      it 'returns the warning zone' do
        expect(measure.zone_for_score(1.0)).to eq measure.warning_zone
      end
    end

    context 'when the score is 5.0' do
      it 'returns the ideal zone' do
        expect(measure.zone_for_score(5.0)).to eq measure.ideal_zone
      end
    end

    context 'when the score is right on the benchmark' do
      it 'returns the higher zone' do
        expect(measure.zone_for_score(1.5)).to eq measure.watch_zone
        expect(measure.zone_for_score(2.5)).to eq measure.growth_zone
        expect(measure.zone_for_score(3.5)).to eq measure.approval_zone
        expect(measure.zone_for_score(4.5)).to eq measure.ideal_zone
      end
    end
  end
end
