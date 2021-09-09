require "rails_helper"

RSpec.feature "School dashboard", type: feature do
  let(:district) { District.create name: 'Winchester' }
  let(:school) {
    School.create name: 'Winchester High School', slug: 'winchester-high-school', district: district
  }

  scenario "User views a school dashboard" do
    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).to have_text(school.name)
  end
end
