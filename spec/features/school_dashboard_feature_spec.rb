require 'rails_helper'

feature 'School dashboard', type: feature do
  let(:district) { District.find_by_slug 'winchester' }
  let(:school) { School.find_by_slug 'winchester-high-school' }
  let(:school_in_same_district) { School.find_by_slug 'muraco-elementary-school' }

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

  let(:username) { 'winchester' }
  let(:password) { 'winchester!' }

  before :each do
    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                              survey_item: survey_item_1_for_measure_1A_i, likert_score: 4
    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                              survey_item: survey_item_2_for_measure_1A_i, likert_score: 5

    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                              survey_item: survey_item_1_for_measure_2A_i, likert_score: 5
    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                              survey_item: survey_item_2_for_measure_2A_i, likert_score: 5

    SurveyItemResponse.create response_id: rand.to_s, academic_year: ay_2020_21, school: school,
                              survey_item: survey_item_1_for_measure_4C_i, likert_score: 1
  end

  scenario 'User authentication fails' do
    page.driver.browser.basic_authorize('wrong username', 'wrong password')

    visit "/districts/winchester/schools/#{school.slug}/dashboard?year=2020-21"

    expect(page).not_to have_text(school.name)
  end

  scenario 'User views a school dashboard' do
    page.driver.browser.basic_authorize(username, password)

    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    expect(page).to have_select('academic-year', selected: '2020 – 2021')
    expect(page).to have_select('district', selected: 'Winchester')
    expect(page).to have_select('school', selected: 'Winchester High School')

    expect(page).to have_text(school.name)

    expect(page).to have_text('Professional Qualifications')
    professional_qualifications_row = measure_row_bars.find { |item| item['data-for-measure-id'] == '1A-i' }
    expect(professional_qualifications_row['width']).to eq '20.66%'
    expect(professional_qualifications_row['x']).to eq '50%'

    expect(page).to have_text('Student Physical Safety')
    student_physical_safety_row = measure_row_bars.find { |item| item['data-for-measure-id'] == '2A-i' }
    expect(student_physical_safety_row['width']).to eq '50.0%'
    expect(student_physical_safety_row['x']).to eq '50%'

    expect(page).to have_text('Problem Solving Emphasis')
    problem_solving_emphasis_row = measure_row_bars.find { |item| item['data-for-measure-id'] == '4C-i' }
    expect(problem_solving_emphasis_row['width']).to eq '50.0%'
    expect(problem_solving_emphasis_row['x']).to eq '0.0%'

    page.assert_selector('.measure-row-bar', count: Measure.count)
    professional_qualifications_row_index = measure_row_bars.find_index { |item| item['data-for-measure-id'] == '1A-i' }
    student_physical_safety_row_index = measure_row_bars.find_index { |item| item['data-for-measure-id'] == '2A-i' }
    problem_solving_emphasis_row_index = measure_row_bars.find_index { |item| item['data-for-measure-id'] == '4C-i' }
    expect(student_physical_safety_row_index).to be < professional_qualifications_row_index
    expect(professional_qualifications_row_index).to be < problem_solving_emphasis_row_index
  end

    # visit photos_path
    # assert_selector 'h1', text: 'Photos'
    # assert_equal 1, all('.photo-deletable').count
    # click_on 'Delete'
    # page.driver.browser.switch_to.alert.accept
  scenario 'user sees schools in the same district' do
    page.driver.browser.basic_authorize(username, password)
    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    assert_selector "h1", text: school.name

    expected_num_of_schools = district.schools.count
    expect(page.all('.school-options').count).to eq expected_num_of_schools
    expect(page.all('.school-options[selected]').count).to eq 1
    expect(page.all('.school-options[selected]')[0].text).to eq 'Winchester High School'

    school_options = page.all('.school-options')
    school_options.each_with_index do |school , index| 
      break if index == school_options.length-1
      expect(school.text).to be < school_options[index+1].text
    end
  end

  scenario 'user sees all districts in dropdown menu'  do
    page.driver.browser.basic_authorize(username, password)
    visit "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{ay_2020_21.range}"

    expected_num_of_districts = District.count
    expect(page.all('.district-options').count).to eq expected_num_of_districts
    expect(page.all('.district-options[selected]').count).to eq 1
    expect(page.all('.district-options[selected]')[0].text).to eq 'Winchester'

    district_options = page.all('.district-options')
    district_options.each_with_index do |district , index| 
      break if index == district_options.length-1
      expect(district.text).to be < district_options[index+1].text
    end
  end

end
