require 'rails_helper'

RSpec.describe "districts/show", type: :view do
  before(:each) do
    @district = assign(:district, District.create!(
      :name => "District Name",
      :state_id => 2
    ))

    schools = []
    3.times { |i| schools << @district.schools.create!(name: "School #{i}")}
    @schools = assign(:schools, schools)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/District Name/)
    expect(rendered).to match(/2/)
    3.times do |i|
      expect(rendered).to match(/School #{i}/)
    end
  end
end
