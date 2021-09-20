require 'rails_helper'

describe SurveyItem, type: :model do
  it('has all the questions') do
    expect(SurveyItem.count).to eq 137
  end
end
