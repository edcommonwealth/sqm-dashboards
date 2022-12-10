require 'rails_helper'

describe 'home/index' do
  let(:school) { create(:school) }
  let(:district) { create(:district) }
  subject { Nokogiri::HTML(rendered) }

  before :each do
    assign :districts, [create(:district), create(:district)]
    assign :categories, [CategoryPresenter.new(category: create(:category))]
    render
  end

  it 'renders a dropdown with districts and a select a district prompt' do
    expect(subject.css('#district-dropdown option').count).to eq 3
  end
end
