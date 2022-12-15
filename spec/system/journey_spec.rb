require 'rails_helper'
include AnalyzeHelper

describe 'District Admin', js: true do
  let(:district) { District.find_by_slug 'winchester' }
  let(:different_district) { District.find_by_slug 'wareham' }
  let(:school) { School.find_by_slug 'winchester-high-school' }
  let(:school_in_same_district) { School.find_by_slug 'muraco-elementary-school' }
  let(:first_school_in_wareham) { School.find_by_slug 'john-william-decas-elementary-school' }

  let(:category) { Category.find_by_name('Teachers & Leadership') }
  let(:different_category) { Category.find_by_name('School Culture') }
  let(:subcategory) { Subcategory.find_by_name('Teachers & The Teaching Environment') }
  let(:different_subcategory) { Subcategory.find_by_name('Relationships') }
  let(:measures_for_subcategory) { Measure.where(subcategory:) }
  let(:scales_for_subcategory) { Scale.where(measure: measures_for_subcategory) }
  let(:survey_items_for_subcategory) { SurveyItem.where(scale: scales_for_subcategory) }

  let(:measure_1A_i) { Measure.find_by_measure_id('1A-i') }
  let(:measure_2A_i) { Measure.find_by_measure_id('2A-i') }
  let(:measure_2A_ii) { Measure.find_by_measure_id('2A-ii') }
  let(:measure_4C_i) { Measure.find_by_measure_id('4C-i') }
  let(:measure_with_no_survey_responses) { Measure.find_by_measure_id('3A-i') }

  let(:survey_items_for_measure_1A_i) { measure_1A_i.survey_items }
  let(:survey_items_for_measure_2A_i) { measure_2A_i.survey_items }
  let(:survey_items_for_measure_2A_ii) { measure_2A_ii.survey_items }
  let(:survey_items_for_measure_4C_i) { measure_4C_i.survey_items }

  let(:ay_2021_22) { AcademicYear.find_by_range '2021-22' }
  let(:ay_2019_20) { AcademicYear.find_by_range '2019-20' }
  let(:response_rates) do
    [ay_2021_22, ay_2019_20].each do |academic_year|
      [school, school_in_same_district, first_school_in_wareham].each do |school|
        [subcategory, different_subcategory].each do |subcategory|
          ResponseRate.create!(subcategory:, school:, academic_year:, student_response_rate: 100, teacher_response_rate: 100,
                               meets_student_threshold: true, meets_teacher_threshold: true)
        end
      end
    end
  end

  # let(:username) { 'winchester' }
  # let(:password) { 'winchester!' }
  let(:respondents) do
    respondents = Respondent.where(school:, academic_year: ay_2021_22).first
    respondents.total_students = 8
    respondents.total_teachers = 8
    respondents.save

    respondents = Respondent.where(school:, academic_year: ay_2019_20).first
    respondents.total_students = 8
    respondents.total_teachers = 8
    respondents.save
  end

  before :each do
    Rails.application.load_seed

    respondents
    response_rates
    survey_item_responses = []

    survey_items_for_measure_1A_i.each do |survey_item|
      SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    survey_items_for_measure_2A_i.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 5)
      end
    end

    survey_items_for_measure_2A_ii.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 5)
      end
    end

    survey_items_for_measure_4C_i.each do |survey_item|
      SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 1)
      end
    end

    survey_items_for_subcategory.each do |survey_item|
      2.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    SurveyItemResponse.import survey_item_responses
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'navigates through the site' do
    # page.driver.basic_authorize(username, password)

    visit '/welcome'
    expect(page).to have_text('Teachers & Leadership')
    go_to_school_overview_from_welcome_page(district, school)

    district_admin_sees_overview_content

    click_on 'Teachers & Leadership'
    district_admin_sees_browse_content

    click_on 'Overview'
    district_admin_sees_overview_content

    click_on 'Analyze'
    district_admin_sees_analyze_content

    go_to_different_category(different_category)
    district_admin_sees_category_change

    go_to_different_subcategory(different_subcategory)
    district_admin_sees_subcategory_change

    click_on 'Browse'
    district_admin_sees_browse_content

    click_on 'School Culture'
    expect(page).to have_text('Measures the degree to which the school environment is safe, caring, and academically-oriented. It considers factors like bullying, student-teacher relationships, and student valuing of learning.')

    go_to_different_school_in_same_district(school_in_same_district)
    district_admin_sees_schools_change

    go_to_different_district(different_district)
    district_admin_sees_district_change

    go_to_different_year(ay_2019_20)
    district_admin_sees_year_change
  end
end

private

def district_admin_sees_professional_qualifications
  expect(page).to have_text('Professional Qualifications')
  expect(page).to have_css("[data-for-measure-id='1A-i'][width='2.99%'][x='60%']")
end

def district_admin_sees_student_physical_safety
  expect(page).to have_text('Student Physical Safety')

  expect(page).to have_css("[data-for-measure-id='2A-i'][width='40.0%'][x='60%']")
end

def district_admin_sees_problem_solving_emphasis
  expect(page).to have_text('Problem Solving Emphasis')
  expect(page).to have_css("[data-for-measure-id='4C-i'][width='60.0%'][x='0.0%']")
end

def go_to_school_overview_from_welcome_page(district, school)
  expect(page).to have_select('district', selected: 'Select a District')
  select district.name, from: 'district-dropdown'
  expect(page).to have_select('school', selected: 'Select a School')
  select school.name, from: 'school-dropdown'
  expect(page).to have_select('school', selected: 'Winchester High School')

  click_on 'Go'
end

def go_to_different_school_in_same_district(school)
  select school.name, from: 'select-school'
end

def go_to_different_district(district)
  select district.name, from: 'select-district'
end

def go_to_different_year(year)
  select year.formatted_range, from: 'select-academic-year'
end

def got_to_analyze_page; end

def district_admin_sees_schools_change
  expected_path = "/districts/#{school_in_same_district.district.slug}/schools/#{school_in_same_district.slug}/browse/teachers-and-leadership?year=#{ay_2021_22.range}"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_district_change
  expected_path = "/districts/#{different_district.slug}/schools/#{different_district.schools.alphabetic.first.slug}/browse/teachers-and-leadership?year=#{ay_2021_22.range}"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_year_change
  expected_path = "/districts/#{different_district.slug}/schools/#{different_district.schools.alphabetic.first.slug}/browse/teachers-and-leadership?year=2019-20"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_overview_content
  expect(page).to have_select('academic-year', selected: '2021 – 2022')
  expect(page).to have_select('district', selected: 'Winchester')
  expect(page).to have_select('school', selected: 'Winchester High School')
  expect(page).to have_text(school.name)

  district_admin_sees_professional_qualifications
  district_admin_sees_student_physical_safety
  district_admin_sees_problem_solving_emphasis

  page.assert_selector('.measure-row-bar', count: 6)
end

def district_admin_sees_browse_content
  expect(page).to have_text('Teachers & Leadership')
  expect(page).to have_text('Approval')
end

def district_admin_sees_analyze_content
  expect(page).to have_text('1:Teachers & Leadership > 1A:Teachers & The Teaching Environment')
end

def go_to_different_category(category)
  select category.name, from: 'select-category'
end

def district_admin_sees_category_change
  expect(page).to have_text '2A:Safety'
end

def go_to_different_subcategory(subcategory)
  select subcategory.name, from: 'select-subcategory'
end

def district_admin_sees_subcategory_change
  expect(page).to have_text('Relationships')
end
