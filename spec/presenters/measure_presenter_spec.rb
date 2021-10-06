require 'rails_helper'

describe MeasurePresenter do
  let(:academic_year) { create(:academic_year, range: '1989-90') }
  let(:school) { create(:school, name: 'Best School') }
  let(:measure) do
    create(:measure).tap do |measure|
      survey_item = create(:survey_item, measure: measure)
      create(:survey_item_response, survey_item: survey_item, academic_year: academic_year, school: school, likert_score: 1)
      create(:survey_item_response, survey_item: survey_item, academic_year: academic_year, school: school, likert_score: 5)
    end
  end
  let(:measure_presenter) { MeasurePresenter.new(measure: measure, academic_year: academic_year, school: school) }

  it 'creates a gauge presenter that presents the average likert score' do
    expect(measure_presenter.gauge_presenter.title).to eq 'Growth'
  end
end
