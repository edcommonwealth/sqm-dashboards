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
end
