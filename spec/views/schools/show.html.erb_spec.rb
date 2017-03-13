require 'rails_helper'

RSpec.describe "schools/show", type: :view do
  before(:each) do
    @school_categories = []
    @school = assign(:school, School.create!(
      :name => "School",
      :district => District.create(name: 'District')
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/School/)
    expect(rendered).to match(/District/)
  end
end
