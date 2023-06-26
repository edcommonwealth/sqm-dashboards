require 'rails_helper'
include AnalyzeHelper

describe 'District Admin', js: true do
  let(:district) { District.find_by_slug 'Lowell' }
  let(:school) { School.find_by_slug 'abraham-lincoln-elementary-school' }
  let(:school_in_same_district) { School.find_by_slug 'adie-day-school' }

  let(:category) { Category.find_by_name('Teachers & Leadership') }
  let(:different_category) { Category.find_by_name('School Culture') }
  let(:subcategory) { Subcategory.find_by_name('Teachers & The Teaching Environment') }
  let(:different_subcategory) { Subcategory.find_by_name('Relationships') }
  let(:measures_for_subcategory) { Measure.where(subcategory:) }
  let(:scales_for_subcategory) { Scale.where(measure: measures_for_subcategory) }
  let(:survey_items_for_subcategory) { SurveyItem.where(scale: scales_for_subcategory) }

  let(:measure_1A_i) { Measure.find_by_measure_id('1A-i') }
  let(:measure_1A_ii) { Measure.find_by_measure_id('1A-ii') }
  let(:measure_1A_iii) { Measure.find_by_measure_id('1A-iii') }
  let(:measure_1B_i) { Measure.find_by_measure_id('1B-i') }
  let(:measure_1B_ii) { Measure.find_by_measure_id('1B-ii') }
  let(:measure_2A_i) { Measure.find_by_measure_id('2A-i') }
  let(:measure_2A_ii) { Measure.find_by_measure_id('2A-ii') }
  let(:measure_4C_i) { Measure.find_by_measure_id('4C-i') }
  let(:measure_with_no_survey_responses) { Measure.find_by_measure_id('3A-i') }

  let(:survey_items_for_measure_1A_i) { measure_1A_i.survey_items }
  let(:survey_items_for_measure_1A_ii) { measure_1A_ii.survey_items }
  let(:survey_items_for_measure_1A_iii) { measure_1A_iii.survey_items }
  let(:survey_items_for_measure_1B_i) { measure_1B_i.survey_items }
  let(:survey_items_for_measure_1B_ii) { measure_1B_ii.survey_items }
  let(:survey_items_for_measure_2A_i) { measure_2A_i.survey_items }
  let(:survey_items_for_measure_2A_ii) { measure_2A_ii.survey_items }
  let(:survey_items_for_measure_4C_i) { measure_4C_i.survey_items }

  let(:ay_2021_22) { AcademicYear.find_by_range '2021-22' }
  let(:ay_2019_20) { AcademicYear.find_by_range '2019-20' }
  let(:response_rates) do
    [ay_2021_22, ay_2019_20].each do |academic_year|
      [school, school_in_same_district].each do |school|
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
    respondent = Respondent.find_or_initialize_by(school:, academic_year: ay_2021_22)
    respondent.total_students = 8
    respondent.total_teachers = 8
    respondent.one = 20
    respondent.save

    respondent = Respondent.find_or_initialize_by(school:, academic_year: ay_2019_20)
    respondent.total_students = 8
    respondent.total_teachers = 8
    respondent.one = 20
    respondent.save
  end

  before do
    Rails.application.load_seed

    district
    school
    respondents
    response_rates
    survey_item_responses = []

    survey_items_for_measure_1A_i.each do |survey_item|
      SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    survey_items_for_measure_1A_ii.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    survey_items_for_measure_1A_iii.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    survey_items_for_measure_1B_i.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    survey_items_for_measure_1B_ii.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4)
      end
    end

    survey_items_for_measure_2A_i.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 5, grade: 1)
      end
    end

    survey_items_for_measure_2A_ii.each do |survey_item|
      SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 5, grade: 1)
      end
    end

    survey_items_for_measure_4C_i.each do |survey_item|
      SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 1, grade: 1)
      end
    end

    survey_items_for_subcategory.each do |survey_item|
      2.times do
        survey_item_responses << SurveyItemResponse.new(response_id: rand.to_s, academic_year: ay_2021_22,
                                                        school:, survey_item:, likert_score: 4, grade: 1)
      end
    end

    SurveyItemResponse.import survey_item_responses
  end

  after do
    DatabaseCleaner.clean
  end

  it 'navigates through the site' do
    # page.driver.basic_authorize(username, password)

    visit '/welcome'
    expect(page).to have_text('Teachers & Leadership')
    go_to_school_overview_from_welcome_page(school)
    district_admin_sees_overview_content

    go_to_different_year(ay_2021_22)
    go_to_year_with_data

    district_admin_sees_overview_content

    # click_on 'Teachers & Leadership'
    # district_admin_sees_browse_content

    # click_on 'Overview'
    # district_admin_sees_overview_content

    # click_on 'Analyze'
    # district_admin_sees_analyze_content

    # go_to_different_category(different_category)
    # district_admin_sees_category_change

    # go_to_different_subcategory(different_subcategory)
    # district_admin_sees_subcategory_change

    # click_on 'Browse'
    # district_admin_sees_browse_content

    # click_on 'School Culture'
    # expect(page).to have_text('Measures the degree to which the school environment is safe, caring, and academically-oriented. It considers factors like bullying, student-teacher relationships, and student valuing of learning.')

    # go_to_different_school_in_same_district(school_in_same_district)
    # district_admin_sees_schools_change

    # go_to_different_year(ay_2019_20)
    # district_admin_sees_year_change
  end
end

private

def district_admin_sees_professional_qualifications
  expect(page).to have_text('Professional Qualifications')
  expect(page).to have_css("[data-for-measure-id='1A-i']")

  # TODO: cutpoints in source of truth have changed so the cutpoints have moved and '2.99%' is no longer a valid value for this cutpoint.
  # expect(page).to have_css("[data-for-measure-id='1A-i'][width='2.99%'][x='60%']")
end

def district_admin_sees_student_physical_safety
  expect(page).to have_text('Student Physical Safety')

  expect(page).to have_css("[data-for-measure-id='2A-i'][width='40.0%'][x='60%']")
end

def district_admin_sees_problem_solving_emphasis
  expect(page).to have_text('Problem Solving')
  expect(page).to have_css("[data-for-measure-id='4C-i'][width='60.0%'][x='0.0%']")
end

def go_to_school_overview_from_welcome_page(school)
  expect(page).to have_select('school', selected: 'Select a School')
  select school.name, from: 'school-dropdown'
  expect(page).to have_select('school', selected: 'Abraham Lincoln Elementary School')
  expect(page).to have_xpath('//a[@class="mx-4 btn btn-secondary"]')

  click_on 'Go'
end

def go_to_different_school_in_same_district(school)
  select school.name, from: 'select-school'
end

def go_to_different_year(year)
  select year.formatted_range, from: 'select-academic-year'
end

def district_admin_sees_schools_change
  expected_path = "/districts/#{school_in_same_district.district.slug}/schools/#{school_in_same_district.slug}/browse/teachers-and-leadership?year=#{ay_2021_22.range}"
  expect(page).to have_current_path(expected_path)
end

def go_to_year_with_data
  expected_path = "/districts/#{school.district.slug}/schools/#{school.slug}/overview?year=2021-22"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_overview_content
  expect(page).to have_select('academic-year', selected: '2021 – 2022')
  expect(page).to have_select('school', selected: 'Abraham Lincoln Elementary School')
  expect(page).to have_text(school.name)

  district_admin_sees_professional_qualifications
  district_admin_sees_student_physical_safety
  district_admin_sees_problem_solving_emphasis

  page.assert_selector('.measure-row-bar', count: 8)
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
