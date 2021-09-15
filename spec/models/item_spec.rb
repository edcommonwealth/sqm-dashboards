require 'rails_helper'

describe Item, type: :model do
  it('has all the questions') do
    expect(Item.count).to eq 153
  end
end
