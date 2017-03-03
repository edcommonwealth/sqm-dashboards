require 'rails_helper'

RSpec.describe "categories/new", type: :view do
  before(:each) do
    assign(:category, Category.new(
      :name => "MyString",
      :blurb => "MyString",
      :description => "MyText",
      :external_id => "MyString",
      :parent_category_id => 1
    ))
  end

  it "renders new category form" do
    render

    assert_select "form[action=?][method=?]", categories_path, "post" do

      assert_select "input#category_name[name=?]", "category[name]"

      assert_select "input#category_blurb[name=?]", "category[blurb]"

      assert_select "textarea#category_description[name=?]", "category[description]"

      assert_select "input#category_external_id[name=?]", "category[external_id]"

      assert_select "input#category_parent_category_id[name=?]", "category[parent_category_id]"
    end
  end
end
