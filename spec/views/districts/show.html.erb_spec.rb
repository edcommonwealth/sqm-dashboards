require 'rails_helper'

RSpec.describe "districts/show", type: :view do
  before(:each) do
    @district = assign(:district, District.create!(
      :name => "Name",
      :state_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
  end
end
