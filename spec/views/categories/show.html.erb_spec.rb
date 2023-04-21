require 'rails_helper'
include GaugeHelper

describe 'categories/show' do
  subject { Nokogiri::HTML(rendered) }
  let(:academic_year) { create(:academic_year, range: '1989-90') }
  let(:school) { create(:school, name: 'Best School') }
  let(:category) { create(:category, name: 'Some Category', description: 'Some description of the category') }
  let(:category_presenter) { CategoryPresenter.new(category:) }
  let(:subcategory1) do
    create(:subcategory, category:, name: 'A subcategory', description: 'Some description of the subcategory')
  end
  let(:subcategory2) do
    create(:subcategory, category:, name: 'Another subcategory',
                         description: 'Another description of the subcategory')
  end
  let(:measure1) { create(:measure, subcategory: subcategory1) }
  let(:scale1) { create(:student_scale, measure: measure1) }
  let(:survey_item1) do
    create(:student_survey_item, scale: scale1, watch_low_benchmark: 1.5, growth_low_benchmark: 2.5,
                                 approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
  end
  let(:measure2) do
    create(:measure, name: 'The second measure name', description: 'The second measure description', measure_id: '1A-i',
                     subcategory: subcategory2)
  end
  let(:scale2) { create(:student_scale, measure: measure2) }
  let(:scale3) { create(:teacher_scale, measure: measure2) }
  let(:student_survey_item) do
    create(:student_survey_item, scale: scale2, prompt: 'Some prompt for student data',
                                 watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
  end
  let(:teacher_survey_item) { create(:teacher_survey_item, scale: scale3, prompt: 'Some prompt for teacher data') }
  let(:admin_data_scale) { create(:scale, measure: measure2) }
  let(:admin_data_item) do
    create(:admin_data_item, scale: admin_data_scale, description: 'Some admin data item description',
                             watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
  end

  before :each do
    academic_year
    school

    category
    category_presenter

    subcategory1
    subcategory2

    measure1
    scale1
    survey_item1
    create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item1,
                                                                                       academic_year:, school:, likert_score: 3)

    measure2
    scale2
    scale3
    student_survey_item
    create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                survey_item: student_survey_item, academic_year:, school:, likert_score: 5)

    teacher_survey_item
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                survey_item: teacher_survey_item, academic_year:, school:, likert_score: 3)

    admin_data_scale
    admin_data_item

    assign :category, category_presenter

    assign :categories, [category_presenter]
    assign :school, school
    assign :district, create(:district)
    assign :academic_year, academic_year
    assign :academic_years, [academic_year]

    create(:respondent, school:, academic_year:)
  end

  context 'for each category' do
    before do
      render
    end
    it 'renders the category name and description' do
      expect(rendered).to match(/Some Category/)
      expect(rendered).to match(/Some description of the category/)
    end
  end

  context 'for each subcategory' do
    before do
      render
    end
    it 'renders the subcategory name' do
      expect(rendered).to match(/A subcategory/)
      expect(rendered).to match(/Another subcategory/)
    end

    it 'renders the subcategory description' do
      expect(rendered).to match(/Some description of the subcategory/)
      expect(rendered).to match(/Another description of the subcategory/)
    end

    it 'renders the zone title and fill color for the gauge graph' do
      expect(rendered).to match(/Growth/)
      expect(rendered).to match(/fill-growth/)
    end
  end

  context 'for each measure' do
    before do
      render
    end
    it 'renders the measure name' do
      expect(rendered).to match(/The second measure name/)
    end

    it 'renders the measure description' do
      expect(rendered).to match(/The second measure description/)
    end

    it 'renders a gauge graph and the zone title color' do
      expect(rendered).to match(/Approval/)
      expect(rendered).to match(/fill-approval/)
    end

    it 'renders the prompts for survey items and admin data that make up the measure' do
      expect(rendered).to match(/Some prompt for student data/)
      expect(rendered).to match(/Some prompt for teacher data/)
      expect(rendered).to match(/Some admin data item description/)
    end
  end

  context 'when the measure does NOT have admin data values' do
    before do
      render
    end
    it 'renders the insufficient data exclamation point icon' do
      exclamation_points = subject.css('[data-exclamation-point]')
      expect(exclamation_points.first.attribute('data-exclamation-point').value).to eq 'admin-data-items-1A-i'
    end
    it 'renders the insufficient data message' do
      exclamation_points = subject.css('[data-insufficient-data-message]')
      expect(exclamation_points.first.attribute('data-insufficient-data-message').value).to eq 'admin-data-items-1A-i-limited availability'
    end
    it 'renders the insufficient data exclamation point icons next to the description of the missing admin data item' do
      exclamation_points = subject.css('[data-missing-data]')
      expect(exclamation_points.first.attribute('data-missing-data').value).to eq "#{admin_data_item.admin_data_item_id}"
    end
  end

  context 'when the measure DOES have admin data values' do
    before :each do
      create(:admin_data_value, admin_data_item:, school:, academic_year:, likert_score: 2)
      render
    end
    it 'does not render the insufficient data exclamation point icon' do
      exclamation_points = subject.css('[data-exclamation-point]')
      expect(exclamation_points.count).to eq 0
    end

    it 'does not render the insufficient data message ' do
      exclamation_points = subject.css('[data-insufficient-data-message]')
      expect(exclamation_points.count).to eq 0
    end

    it 'Does NOT render the insufficient data exclamation point icons next to the description of the missing admin data item' do
      exclamation_points = subject.css('[data-missing-data]')
      expect(exclamation_points.count).to eq 0
    end
  end
end
