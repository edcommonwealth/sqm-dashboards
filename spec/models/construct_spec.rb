require 'rails_helper'

describe Construct, type: :model do
  it('has all the constructs') do
    expect(Construct.count).to eq 34
  end

  it 'returns the construct for the given construct id' do
    construct = Construct.find_by_construct_id('1A-i')

    expect(construct.name).to eq 'Professional Qualifications'
    expect(construct.warning_zone).to eq Construct::Zone.new(1.0, 2.49, :warning)
    expect(construct.watch_zone).to eq Construct::Zone.new(2.49, 3.0, :watch)
    expect(construct.growth_zone).to eq Construct::Zone.new(3.0, 3.5, :growth)
    expect(construct.approval_zone).to eq Construct::Zone.new(3.5, 4.71, :approval)
    expect(construct.ideal_zone).to eq Construct::Zone.new(4.71, 5.0, :ideal)
  end

  describe '#zone_for_score' do
    let(:construct) {
      Construct.new watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5
    }

    context 'when the score is 1.0' do
      it 'returns the warning zone' do
        expect(construct.zone_for_score(1.0)).to eq construct.warning_zone
      end
    end

    context 'when the score is 5.0' do
      it 'returns the ideal zone' do
        expect(construct.zone_for_score(5.0)).to eq construct.ideal_zone
      end
    end

    context 'when the score is right on the benchmark' do
      it 'returns the higher zone' do
        expect(construct.zone_for_score(1.5)).to eq construct.watch_zone
        expect(construct.zone_for_score(2.5)).to eq construct.growth_zone
        expect(construct.zone_for_score(3.5)).to eq construct.approval_zone
        expect(construct.zone_for_score(4.5)).to eq construct.ideal_zone
      end
    end
  end
end
