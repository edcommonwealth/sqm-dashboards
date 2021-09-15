require "rails_helper"

feature "School dashboard", type: feature do
  let(:district) { District.create name: 'Winchester' }
  let(:school) {
    School.create name: 'Winchester High School', slug: 'winchester-high-school', district: district
  }

  scenario "User authentication fails" do
    page.driver.browser.basic_authorize('wrong username', 'wrong password')

    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).not_to have_text(school.name)
  end

  scenario "User views a school dashboard" do
    page.driver.browser.basic_authorize(username, password)

    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).to have_text(school.name)
    expect(page).to have_text('Professional Qualifications')
  end

  let(:username) { 'winchester' }
  let(:password) { 'winchester!' }
end
