require 'rails_helper'

RSpec.describe "categories/index", type: :view do
  before(:each) do
    assign(:categories, [
      Category.create!(
        :name => "Name",
        :blurb => "Blurb",
        :description => "MyText",
        :external_id => "External",
        :parent_category_id => 2
      ),
      Category.create!(
        :name => "Name",
        :blurb => "Blurb",
        :description => "MyText",
        :external_id => "External",
        :parent_category_id => 2
      )
    ])
  end

  it "renders a list of categories" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Blurb".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "External".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
