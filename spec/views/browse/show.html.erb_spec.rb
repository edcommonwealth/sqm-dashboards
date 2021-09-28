require 'rails_helper'

describe 'browse/show.html.erb' do
  before :each do
    academic_year = create(:academic_year, range: '1989-90')
    school = create(:school, name: 'Best School')

    category = create(:sqm_category, name: 'Some Category')

    subcategory1 = create(:subcategory, sqm_category: category, name: 'A subcategory')
    subcategory2 = create(:subcategory_with_measures, sqm_category: category, name: 'Another subcategory')

    measure1 = create(:measure, subcategory: subcategory1, watch_low_benchmark: 1.5, growth_low_benchmark: 2.5, approval_low_benchmark: 3.5, ideal_low_benchmark: 4.5)

    survey_item1 = create(:survey_item, measure: measure1)

    survey_item_response1 = create(:survey_item_response, survey_item: survey_item1, academic_year: academic_year, school: school, likert_score: 3)

    assign :category, CategoryPresenter.new(category: category, academic_year: academic_year, school: school)

    render
  end

  it 'renders the category name' do
    expect(rendered).to match /Some Category/
  end

  context 'for each subcategory' do
    it 'renders the subcategory name' do
      expect(rendered).to match /A subcategory/
      expect(rendered).to match /Another subcategory/
    end

    it 'renders the zone title and fill color for the gauge graph' do
      expect(rendered).to match /Growth/
      expect(rendered).to match /fill-growth/
    end
  end
end
