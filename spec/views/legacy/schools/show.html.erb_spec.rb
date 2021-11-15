require 'rails_helper'

module Legacy
  RSpec.describe "legacy/schools/show", type: :view do
    before(:each) do
      @school_categories = []
      @school = assign(:school, School.create!(
        :name => "School",
        :district => District.create(name: 'District')
      ))
    end

    it "renders attributes in <p>" do
      render(template: "legacy/schools/show")
      expect(rendered).to match(/School/)
      expect(rendered).to match(/District/)
    end
  end
end
