require 'rails_helper'

RSpec.describe "categories/show", type: :view do
  before(:each) do
    @school = assign(:school, School.create(name: 'School'))
    @category = assign(:category, Category.create!(
      :name => "Category",
      :description => "MyText",
      :parent_category => Category.create(name: 'Teachers And The Teaching Environment')
    ))
    @school_category = assign(:school_category, SchoolCategory.create(school: @school, category: @category))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Category/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Teachers And The Teaching Environment/)
  end
end
