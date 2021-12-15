require 'rails_helper'

describe 'categories/show.html.erb' do
  before :each do
    academic_year = create(:academic_year, range: '1989-90')
    school = create(:school, name: 'Best School')

    category = create(:category, name: 'Some Category', description: 'Some description of the category')
    category_presenter = CategoryPresenter.new(category: category)

    subcategory1 = create(:subcategory, category: category, name: 'A subcategory',
                                        description: 'Some description of the subcategory')
    subcategory2 = create(:subcategory_with_measures, category: category, name: 'Another subcategory',
                                                      description: 'Another description of the subcategory')

    measure1 = create(:measure, subcategory: subcategory1)
    survey_item1 = create(:student_survey_item, measure: measure1, watch_low_benchmark: 1.5, growth_low_benchmark: 2.5,
                                                approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
    create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item1,
                                                                                       academic_year: academic_year, school: school, likert_score: 1)

    measure2 = create(:measure, name: 'The second measure name', description: 'The second measure description',
                                subcategory: subcategory1)
    student_survey_item = create(:student_survey_item, measure: measure2, prompt: 'Some prompt for student data',
                                                       watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
    create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                survey_item: student_survey_item, academic_year: academic_year, school: school, likert_score: 5)

    teacher_survey_item = create(:teacher_survey_item, measure: measure2, prompt: 'Some prompt for teacher data')
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                survey_item: teacher_survey_item, academic_year: academic_year, school: school, likert_score: 3)

    admin_data_item = create(:admin_data_item, measure: measure2, description: 'Some admin data item description',
                                               watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
    assign :category, category_presenter

    assign :categories, [category_presenter]
    assign :school, school
    assign :district, create(:district)
    assign :academic_year, academic_year

    render
  end

  it 'renders the category name and description' do
    expect(rendered).to match /Some Category/
    expect(rendered).to match /Some description of the category/
  end

  context 'for each subcategory' do
    it 'renders the subcategory name' do
      expect(rendered).to match /A subcategory/
      expect(rendered).to match /Another subcategory/
    end

    it 'renders the subcategory description' do
      expect(rendered).to match /Some description of the subcategory/
      expect(rendered).to match /Another description of the subcategory/
    end

    it 'renders the zone title and fill color for the gauge graph' do
      expect(rendered).to match /Growth/
      expect(rendered).to match /fill-growth/
    end
  end

  context 'for each measure' do
    it 'renders the measure name' do
      expect(rendered).to match /The second measure name/
    end

    it 'renders the measure description' do
      expect(rendered).to match /The second measure description/
    end

    it 'renders a gauge graph and the zone title color' do
      expect(rendered).to match /Ideal/
      expect(rendered).to match /fill-ideal/
    end

    it 'renders the prompts for survey items and admin data that make up the measure' do
      expect(rendered).to match /Some prompt for student data/
      expect(rendered).to match /Some prompt for teacher data/
      expect(rendered).to match /Some admin data item description/
    end
  end
end
