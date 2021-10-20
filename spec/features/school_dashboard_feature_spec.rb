require 'rails_helper'
# include Rails.application.routes.url_helpers

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

def district_admin_sees_schools_change
  expected_path = "/districts/#{school_in_same_district.district.slug}/schools/#{school_in_same_district.slug}/dashboard?year=2020-21"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_district_change
  expected_path = "/districts/#{different_district.slug}/schools/#{different_district.schools.alphabetic.first.slug}/dashboard?year=2020-21"
  expect(page).to have_current_path(expected_path)
end

def district_admin_sees_measures_in_correct_order
  def index_of_row_for(measure_id:)
    expect(page).to have_css("[data-for-measure-id='#{measure_id}']")
    page.all('rect.measure-row-bar').find_index { |item| item['data-for-measure-id'] == "#{measure_id}" }
  end

  expect(index_of_row_for(measure_id: '2A-i')).to be < index_of_row_for(measure_id: '1A-i')
  expect(index_of_row_for(measure_id: '1A-i')).to be < index_of_row_for(measure_id: '4C-i')
end

def district_admin_sees_dashboard_content
  expect(page).to have_select('academic-year', selected: '2020 – 2021')
  expect(page).to have_select('district', selected: 'Winchester')
  expect(page).to have_select('school', selected: 'Winchester High School')
  expect(page).to have_text(school.name)

  district_admin_sees_professional_qualifications
  district_admin_sees_student_physical_safety
  district_admin_sees_problem_solving_emphasis

  expect(page).to have_css("[data-for-measure-id='3A-i'][width='0.0%']")

  page.assert_selector('.measure-row-bar', count: Measure.count)

  district_admin_sees_measures_in_correct_order
end

def district_admin_sees_browse_content
  expect(page).to have_text('Teachers & Leadership')
  expect(page).to have_text('Approval')
end

feature 'School dashboard', type: feature do
  let(:district) { District.find_by_slug 'winchester' }
  let(:different_district) { District.find_by_slug 'boston' }
  let(:school) { School.find_by_slug 'winchester-high-school' }
  let(:school_in_same_district) { School.find_by_slug 'muraco-elementary-school' }

  let(:category) { SqmCategory.find_by_name('Teachers & Leadership') }
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
    survey_items_for_measure_1A_i.each do |survey_item|
      SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                                survey_item: survey_item, likert_score: 4
    end

    survey_items_for_measure_2A_i.each do |survey_item|
      SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                                survey_item: survey_item, likert_score: 5
    end

    survey_items_for_measure_4C_i.each do |survey_item|
      SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                                survey_item: survey_item, likert_score: 1
    end

    survey_items_for_subcategory.each do |survey_item|
      SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                                survey_item: survey_item, likert_score: 4
    end
  end

  scenario 'User authentication fails' do
    page.driver.browser.basic_authorize('wrong username', 'wrong password')

    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).not_to have_text(school.name)
  end

  scenario 'District Admin navigates the site', js: true do
    page.driver.basic_authorize(username, password)

    visit '/welcome'
    go_to_school_dashboard_from_welcome_page(district, school)

    district_admin_sees_dashboard_content

    go_to_different_school_in_same_district(school_in_same_district)
    district_admin_sees_schools_change

    go_to_different_district(different_district)
    district_admin_sees_district_change
  end

  scenario 'District Admin views a school dashboard' do
    page.driver.browser.basic_authorize(username, password)

    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    district_admin_sees_dashboard_content

    click_on 'View Details', match: :first
    district_admin_sees_browse_content

    click_on 'Dashboard'
    district_admin_sees_dashboard_content

    click_on 'Browse'
    district_admin_sees_browse_content

    click_on 'School Culture'
    expect(page).to have_text('This category measures the degree to which the school environment is safe, caring, and academically-oriented.')
  end

  scenario 'user sees schools in the same district' do
    page.driver.browser.basic_authorize(username, password)
    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    expected_num_of_schools = district.schools.count
    expect(page.all('.school-options').count).to eq expected_num_of_schools
    expect(page.all('.school-options[selected]').count).to eq 1
    expect(page.all('.school-options[selected]')[0].text).to eq 'Winchester High School'
    expect(page.all('.school-options[selected]')[0].value).to eq "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    school_options = page.all('.school-options')
    school_options.each_with_index do |school, index|
      break if index == school_options.length - 1

      expect(school.text).to be < school_options[index + 1].text
    end

    visit "/districts/#{district.slug}/schools/#{school.slug}/browse/teachers-and-leadership?year=#{ay_2020_21.range}"

    expected_num_of_schools = district.schools.count
    expect(page.all('.school-options').count).to eq expected_num_of_schools
    expect(page.all('.school-options[selected]').count).to eq 1
    expect(page.all('.school-options[selected]')[0].text).to eq 'Winchester High School'
    expect(page.all('.school-options[selected]')[0].value).to eq "/districts/#{district.slug}/schools/#{school.slug}/browse/teachers-and-leadership?year=#{ay_2020_21.range}"

    school_options = page.all('.school-options')
    school_options.each_with_index do |school, index|
      break if index == school_options.length - 1

      expect(school.text).to be < school_options[index + 1].text
    end
  end

  scenario 'user sees all districts in dropdown menu' do
    page.driver.browser.basic_authorize(username, password)
    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    expected_num_of_districts = District.count
    expect(page.all('.district-options').count).to eq expected_num_of_districts
    expect(page.all('.district-options[selected]').count).to eq 1
    expect(page.all('.district-options[selected]')[0].text).to eq 'Winchester'
    expect(page.all('.district-options[selected]')[0].value).to eq "/districts/#{district.slug}/schools/#{district.schools.alphabetic.first.slug}/dashboard?year=#{ay_2020_21.range}"

    district_options = page.all('.district-options')
    district_options.each_with_index do |district, index|
      break if index == district_options.length - 1

      expect(district.text).to be < district_options[index + 1].text
    end

    visit "/districts/#{district.slug}/schools/#{school.slug}/browse/teachers-and-leadership?year=#{ay_2020_21.range}"

    expected_num_of_districts = District.count
    expect(page.all('.district-options').count).to eq expected_num_of_districts
    expect(page.all('.district-options[selected]').count).to eq 1
    expect(page.all('.district-options[selected]')[0].text).to eq 'Winchester'
    expect(page.all('.district-options[selected]')[0].value).to eq "/districts/#{district.slug}/schools/#{district.schools.alphabetic.first.slug}/browse/teachers-and-leadership?year=#{ay_2020_21.range}"

    district_options = page.all('.district-options')
    district_options.each_with_index do |district, index|
      break if index == district_options.length - 1

      expect(district.text).to be < district_options[index + 1].text
    end
  end
end
