require "rails_helper"

feature "School dashboard", type: feature do
  let(:district) { District.create name: 'Winchester' }
  let(:school) { School.create name: 'Winchester High School', slug: 'winchester-high-school', district: district }

  let(:construct) { Construct.find_by_construct_id('1A-i') }

  let(:survey_item_1_for_construct) { SurveyItem.create construct: construct }
  let(:survey_item_2_for_construct) { SurveyItem.create construct: construct }

  let(:construct_row_bars) { page.all('rect.construct-row-bar') }

  let(:ay_2020_21) { '2020-21' }

  before :each do
    SurveyResponse.create academic_year: ay_2020_21, school: school, survey_item: survey_item_1_for_construct, likert_score: 4
    SurveyResponse.create academic_year: ay_2020_21, school: school, survey_item: survey_item_2_for_construct, likert_score: 5
  end

  scenario "User authentication fails" do
    page.driver.browser.basic_authorize('wrong username', 'wrong password')

    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).not_to have_text(school.name)
  end

  scenario "User views a school dashboard" do
    page.driver.browser.basic_authorize(username, password)

    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=#{ay_2020_21}"

    expect(page).to have_select('academic-year', selected: '2020 – 2021')
    expect(page).to have_select('district', selected: 'Winchester')
    expect(page).to have_select('school', selected: 'Winchester High School')

    expect(page).to have_text(school.name)
    expect(page).to have_text('Professional Qualifications')
    first_row_bar = construct_row_bars.first
    expect(first_row_bar['width']).to eq '179'
  end

  let(:username) { 'winchester' }
  let(:password) { 'winchester!' }
end
