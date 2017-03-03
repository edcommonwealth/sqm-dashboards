require 'rails_helper'

RSpec.describe "categories/edit", type: :view do
  before(:each) do
    @category = assign(:category, Category.create!(
      :name => "MyString",
      :blurb => "MyString",
      :description => "MyText",
      :external_id => "MyString",
      :parent_category_id => 1
    ))
  end

  it "renders the edit category form" do
    render

    assert_select "form[action=?][method=?]", category_path(@category), "post" do

      assert_select "input#category_name[name=?]", "category[name]"

      assert_select "input#category_blurb[name=?]", "category[blurb]"

      assert_select "textarea#category_description[name=?]", "category[description]"

      assert_select "input#category_external_id[name=?]", "category[external_id]"

      assert_select "input#category_parent_category_id[name=?]", "category[parent_category_id]"
    end
  end
end
