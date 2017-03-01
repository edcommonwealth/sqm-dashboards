require 'rails_helper'

RSpec.describe "districts/new", type: :view do
  before(:each) do
    assign(:district, District.new(
      :name => "MyString",
      :state_id => 1
    ))
  end

  it "renders new district form" do
    render

    assert_select "form[action=?][method=?]", districts_path, "post" do

      assert_select "input#district_name[name=?]", "district[name]"

      assert_select "input#district_state_id[name=?]", "district[state_id]"
    end
  end
end
