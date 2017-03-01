require 'rails_helper'

RSpec.describe "districts/index", type: :view do
  before(:each) do
    assign(:districts, [
      District.create!(
        :name => "Name",
        :state_id => 2
      ),
      District.create!(
        :name => "Name",
        :state_id => 2
      )
    ])
  end

  it "renders a list of districts" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
