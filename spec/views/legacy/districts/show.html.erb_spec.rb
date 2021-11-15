require 'rails_helper'

module Legacy
  RSpec.describe "legacy/districts/show", type: :view do
    before(:each) do
      @district = assign(:district, Legacy::District.create!(
        :name => "Milford",
        :state_id => 2
      ))

      schools = []
      3.times { |i| schools << @district.schools.create!(name: "School #{i}") }
      @schools = assign(:schools, schools)
    end

    it "renders attributes in <p>" do
      render(template: "legacy/districts/show")
      expect(rendered).to match(/Milford/)
      expect(rendered).to match(/2/)
      3.times do |i|
        expect(rendered).to match(/School #{i}/)
      end
    end
  end
end
