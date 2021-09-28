require 'rails_helper'

describe Scale do
  describe '#zone_for_score' do
    let(:scale) {
      Scale.new watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5
    }

    context 'when the score is 1.0' do
      it 'returns the warning zone' do
        expect(scale.zone_for_score(1.0)).to eq scale.warning_zone
      end
    end

    context 'when the score is 5.0' do
      it 'returns the ideal zone' do
        expect(scale.zone_for_score(5.0)).to eq scale.ideal_zone
      end
    end

    context 'when the score is right on the benchmark' do
      it 'returns the higher zone' do
        expect(scale.zone_for_score(1.5)).to eq scale.watch_zone
        expect(scale.zone_for_score(2.5)).to eq scale.growth_zone
        expect(scale.zone_for_score(3.5)).to eq scale.approval_zone
        expect(scale.zone_for_score(4.5)).to eq scale.ideal_zone
      end
    end
  end
end
