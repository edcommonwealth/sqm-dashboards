require 'rails_helper'

RSpec.describe "categories/show", type: :view do
  before(:each) do
    @category = assign(:category, Category.create!(
      :name => "Name",
      :blurb => "Blurb",
      :description => "MyText",
      :external_id => "External",
      :parent_category => Category.create(name: 'Parent Category')
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Blurb/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/External/)
    expect(rendered).to match(/Parent Category/)
  end
end
