require 'rails_helper'

describe 'District Admin', js: true do
  let(:district) { District.find_by_slug 'winchester' }
  let(:different_district) { District.find_by_slug 'boston' }
  let(:school) { School.find_by_slug 'winchester-high-school' }
  let(:school_in_same_district) { School.find_by_slug 'muraco-elementary-school' }

  let(:category) { Category.find_by_name('Teachers & Leadership') }
  let(:subcategory) { Subcategory.find_by_name('Teachers & The Teaching Environment') }
  let(:measures_for_subcategory) { Measure.where(subcategory: subcategory) }
  let(:survey_items_for_subcategory) { SurveyItem.where(measure: measures_for_subcategory) }

  let(:measure_1A_i) { Measure.find_by_measure_id('1A-i') }
  let(:measure_2A_i) { Measure.find_by_measure_id('2A-i') }
  let(:measure_4C_i) { Measure.find_by_measure_id('4C-i') }
  let(:measure_with_no_survey_responses) { Measure.find_by_measure_id('3A-i') }

  let(:survey_item_1_for_measure_1A_i) { SurveyItem.create measure: measure_1A_i, survey_item_id: rand.to_s }
  let(:survey_item_2_for_measure_1A_i) { SurveyItem.create measure: measure_1A_i, survey_item_id: rand.to_s }

  let(:survey_items_for_measure_1A_i) { SurveyItem.where(measure: measure_1A_i) }
  let(:survey_items_for_measure_2A_i) { SurveyItem.where(measure: measure_2A_i) }
  let(:survey_items_for_measure_4C_i) { SurveyItem.where(measure: measure_4C_i) }

  let(:ay_2020_21) { AcademicYear.find_by_range '2020-21' }

  let(:username) { 'winchester' }
  let(:password) { 'winchester!' }

  before :each do
    Rails.application.load_seed

    survey_item_responses = []

    survey_items_for_measure_1A_i.each do |survey_item|
      SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item, likert_score: 4)
      end
    end

    survey_items_for_measure_2A_i.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item, likert_score: 5)
      end
    end

    survey_items_for_measure_4C_i.each do |survey_item|
      SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item, likert_score: 1)
      end
    end

    survey_items_for_subcategory.each do |survey_item|
      200.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2020_21, school: school, survey_item: survey_item, likert_score: 4)
      end
    end

    SurveyItemResponse.import survey_item_responses
  end

  it 'navigates through the site' do
    page.driver.basic_authorize(username, password)

    visit '/welcome'
    expect(page).to have_text("Teachers & Leadership")
    go_to_school_dashboard_from_welcome_page(district, school)

    district_admin_sees_dashboard_content

    click_on 'Teachers & Leadership'
    district_admin_sees_browse_content

    click_on 'Dashboard'
    district_admin_sees_dashboard_content

    click_on 'Browse'
    district_admin_sees_browse_content

    click_on 'School Culture'
    expect(page).to have_text('Measures the degree to which the school environment is safe, caring, and academically-oriented. It considers factors like bullying, student-teacher relationships, and student valuing of learning.')

    go_to_different_school_in_same_district(school_in_same_district)
    district_admin_sees_schools_change

    go_to_different_district(different_district)
    district_admin_sees_district_change
  end
end

private

def district_admin_sees_professional_qualifications
  expect(page).to have_text('Professional Qualifications')
  expect(page).to have_css("[data-for-measure-id='1A-i'][width='8.26%'][x='60%']")
end

def district_admin_sees_student_physical_safety
  expect(page).to have_text('Student Physical Safety')
  expect(page).to have_css("[data-for-measure-id='2A-i'][width='40.0%'][x='60%']")
end

def district_admin_sees_problem_solving_emphasis
  expect(page).to have_text('Problem Solving Emphasis')
  expect(page).to have_css("[data-for-measure-id='4C-i'][width='60.0%'][x='0.0%']")
end

def go_to_school_dashboard_from_welcome_page(district, school)
  select district.name, from: 'district-dropdown'
  select school.name, from: 'school-dropdown'
  click_on 'Go'
end

def go_to_different_school_in_same_district(school)
  select school.name, from: 'select-school'
end

def go_to_different_district(district)
  select district.name, from: 'select-district'
end

def go_to_browse_page_for_school_without_data(school)
  click_on 'Browse'
  select school.name, from: 'select-school'
end

def go_to_dashboard_page_for_school_without_data(school)
  click_on 'Dashboard'
  select school.name, from: 'select-school'
end

def district_admin_sees_schools_change
  expected_path = "/districts/#{school_in_same_district.district.slug}/schools/#{school_in_same_district.slug}/dashboard?year=2020-21"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_district_change
  expected_path = "/districts/#{different_district.slug}/schools/#{different_district.schools.alphabetic.first.slug}/dashboard?year=2020-21"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_dashboard_content
  expect(page).to have_select('academic-year', selected: '2020 – 2021')
  expect(page).to have_select('district', selected: 'Winchester')
  expect(page).to have_select('school', selected: 'Winchester High School')
  expect(page).to have_text(school.name)

  district_admin_sees_professional_qualifications
  district_admin_sees_student_physical_safety
  district_admin_sees_problem_solving_emphasis

  page.assert_selector('.measure-row-bar', count: 5)
end

def district_admin_sees_browse_content
  expect(page).to have_text('Teachers & Leadership')
  expect(page).to have_text('Approval')
end
