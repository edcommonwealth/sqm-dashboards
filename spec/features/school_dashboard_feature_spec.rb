require "rails_helper"

feature "School dashboard", type: feature do
  let(:district) { District.find_by_slug 'winchester' }
  let(:school) { School.find_by_slug 'winchester-high-school' }

  let(:measure) { Measure.find_by_measure_id('1A-i') }

  let(:survey_item_1_for_measure) { SurveyItem.create measure: measure, survey_item_id: '1' }
  let(:survey_item_2_for_measure) { SurveyItem.create measure: measure, survey_item_id: '2' }

  let(:measure_row_bars) { page.all('rect.measure-row-bar') }

  let(:ay_2020_21) { '2020-21' }

  before :each do
    SurveyItemResponse.create academic_year: ay_2020_21, school: school, survey_item: survey_item_1_for_measure, likert_score: 4
    SurveyItemResponse.create academic_year: ay_2020_21, school: school, survey_item: survey_item_2_for_measure, likert_score: 5
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
    first_row_bar = measure_row_bars.first
    expect(first_row_bar['width']).to eq '20.66%'
  end

  let(:username) { 'winchester' }
  let(:password) { 'winchester!' }
end
