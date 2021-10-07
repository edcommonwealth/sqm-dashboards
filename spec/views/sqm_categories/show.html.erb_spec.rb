require 'rails_helper'

describe 'sqm_categories/show.html.erb' do
  before :each do
    academic_year = create(:academic_year, range: '1989-90')
    school = create(:school, name: 'Best School')

    category = create(:sqm_category, name: 'Some Category', description: 'Some description of the category')
    category_presenter = CategoryPresenter.new(category: category, academic_year: academic_year, school: school)

    subcategory1 = create(:subcategory, sqm_category: category, name: 'A subcategory', description: 'Some description of the subcategory')
    subcategory2 = create(:subcategory_with_measures, sqm_category: category, name: 'Another subcategory', description: 'Another description of the subcategory')

    measure1 = create(:measure, subcategory: subcategory1, watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
    survey_item1 = create(:survey_item, measure: measure1)
    create(:survey_item_response, survey_item: survey_item1, academic_year: academic_year, school: school, likert_score: 1)

    measure2 = create(:measure, name: 'The second measure', description: 'The second measure description', subcategory: subcategory1, watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)
    survey_item2 = create(:survey_item, measure: measure2)
    create(:survey_item_response, survey_item: survey_item2, academic_year: academic_year, school: school, likert_score: 5)

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
      expect(rendered).to match /The second measure/
    end

    it 'renders the measure description' do
      expect(rendered).to match /The second measure description/
    end

    it 'renders a gauge graph and the zone title color' do
      expect(rendered).to match /Ideal/
      expect(rendered).to match /fill-ideal/
    end
  end
end
