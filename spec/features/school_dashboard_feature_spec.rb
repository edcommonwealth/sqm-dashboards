require "rails_helper"

feature "School dashboard", type: feature do
  let(:district) { District.find_by_slug 'winchester' }
  let(:school) { School.find_by_slug 'winchester-high-school' }

  let(:measure_1A_i) { Measure.find_by_measure_id('1A-i') }
  let(:measure_2A_i) { Measure.find_by_measure_id('2A-i') }
  let(:measure_4C_i) { Measure.find_by_measure_id('4C-i') }

  let(:survey_item_1_for_measure_1A_i) { SurveyItem.create measure: measure_1A_i, survey_item_id: rand.to_s }
  let(:survey_item_2_for_measure_1A_i) { SurveyItem.create measure: measure_1A_i, survey_item_id: rand.to_s }
  let(:survey_item_1_for_measure_2A_i) { SurveyItem.create measure: measure_2A_i, survey_item_id: rand.to_s }
  let(:survey_item_2_for_measure_2A_i) { SurveyItem.create measure: measure_2A_i, survey_item_id: rand.to_s }
  let(:survey_item_1_for_measure_4C_i) { SurveyItem.create measure: measure_4C_i, survey_item_id: rand.to_s }
  let(:survey_item_2_for_measure_4C_i) { SurveyItem.create measure: measure_4C_i, survey_item_id: rand.to_s }

  let(:measure_row_bars) { page.all('rect.measure-row-bar') }

  let(:ay_2020_21) { AcademicYear.find_by_range '2020-21' }

  before :each do
    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item_1_for_measure_1A_i, likert_score: 4
    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item_2_for_measure_1A_i, likert_score: 5

    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item_1_for_measure_2A_i, likert_score: 5
    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item_2_for_measure_2A_i, likert_score: 5

    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item_1_for_measure_4C_i, likert_score: 1
  end

  scenario "User authentication fails" do
    page.driver.browser.basic_authorize('wrong username', 'wrong password')

    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).not_to have_text(school.name)
  end

  scenario "User views a school dashboard" do
    page.driver.browser.basic_authorize(username, password)

    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    expect(page).to have_select('academic-year', selected: '2020 – 2021')
    expect(page).to have_select('district', selected: 'Winchester')
    expect(page).to have_select('school', selected: 'Winchester High School')

    expect(page).to have_text(school.name)

    expect(page).to have_text('Professional Qualifications')
    expect(measure_row_bars[0]['width']).to eq '20.66%'
    expect(measure_row_bars[0]['x']).to eq '50%'

    expect(page).to have_text('Student Physical Safety')
    expect(measure_row_bars[1]['width']).to eq '50.0%'
    expect(measure_row_bars[1]['x']).to eq '50%'

    expect(page).to have_text('Problem Solving Emphasis')
    expect(measure_row_bars[2]['width']).to eq '50.0%'
    expect(measure_row_bars[2]['x']).to eq '0.0%'
  end

  let(:username) { 'winchester' }
  let(:password) { 'winchester!' }
end
