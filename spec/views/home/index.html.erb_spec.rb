require 'rails_helper'

describe 'home/index.html.erb' do
  subject { Nokogiri::HTML(rendered) }

  before :each do
    assign :districts, [create(:district), create(:district)]
    # assign :schools, [create(:school), create(:school), create(:school)]

    render
  end

  it 'renders a dropdown with districts' do
    expect(subject.css('#district-dropdown option').count).to eq 2
  end

end
