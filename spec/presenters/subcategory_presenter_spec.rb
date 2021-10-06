require 'rails_helper'

describe SubcategoryPresenter do
  let(:academic_year) { create(:academic_year, range: '1989-90') }
  let(:school) { create(:school, name: 'Best School') }
  let(:subcategory_presenter) do
    subcategory = create(:subcategory, name: 'A great subcategory', description: 'A great description')

    measure1 = create(:measure, watch_low_benchmark: 4, growth_low_benchmark: 4.25, approval_low_benchmark: 4.5, ideal_low_benchmark: 4.75, subcategory: subcategory)
    survey_item1 = create(:survey_item, measure: measure1)
    create(:survey_item_response, survey_item: survey_item1, academic_year: academic_year, school: school, likert_score: 1)
    create(:survey_item_response, survey_item: survey_item1, academic_year: academic_year, school: school, likert_score: 5)

    measure2 = create(:measure, watch_low_benchmark: 1.25, growth_low_benchmark: 1.5, approval_low_benchmark: 1.75, ideal_low_benchmark: 2.0, subcategory: subcategory)
    survey_item2 = create(:survey_item, measure: measure2)
    create(:survey_item_response, survey_item: survey_item2, academic_year: academic_year, school: school, likert_score: 1)
    create(:survey_item_response, survey_item: survey_item2, academic_year: academic_year, school: school, likert_score: 5)

    create_survey_item_responses_for_different_years_and_schools(survey_item1)

    return SubcategoryPresenter.new(subcategory: subcategory, academic_year: academic_year, school: school)
  end

  it 'returns the name of the subcategory' do
    expect(subcategory_presenter.name).to eq 'A great subcategory'
  end

  it 'returns the description of the subcategory' do
    expect(subcategory_presenter.description).to eq 'A great description'
  end

  it 'returns a gauge presenter responsible for the aggregate survey item response likert scores' do
    expect(subcategory_presenter.gauge_presenter.title).to eq 'Growth'
  end

  it 'returns a measure presenter for each measure in the subcategory' do
    # expect(category_presenter.subcategories.map(&:name)).to eq ['A subcategory', 'Another subcategory']
  end

  def create_survey_item_responses_for_different_years_and_schools(survey_item)
    create(:survey_item_response, survey_item: survey_item, school: school, likert_score: 1)
    create(:survey_item_response, survey_item: survey_item, academic_year: academic_year, likert_score: 1)
  end

end
