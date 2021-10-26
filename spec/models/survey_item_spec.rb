require 'rails_helper'

# FIXME remove this when seeds.rb is under test
xdescribe SurveyItem, type: :model do
  it('has all the questions') do
    expect(SurveyItem.count).to eq 137
  end
end
