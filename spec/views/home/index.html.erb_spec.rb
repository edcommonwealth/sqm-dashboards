require 'rails_helper'

describe 'home/index.html.erb' do
  subject { Nokogiri::HTML(rendered) }

  before :each do
    assign :districts, [create(:district), create(:district)]
    assign :categories, [create(:sqm_category)]
    render
  end

  it 'renders a dropdown with districts and a select a district prompt' do
    expect(subject.css('#district-dropdown option').count).to eq 3
  end

end
