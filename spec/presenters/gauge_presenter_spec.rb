require 'rails_helper'

describe GaugePresenter do
  # let(:academic_year) { create(:academic_year, range: '1989-90') }
  # let(:school) { create(:school, name: 'Best School') }
  # let(:subcategory_presenter) do
  #   subcategory = create(:subcategory, name: 'A great subcategory')

  #   measure1 = create(:measure, watch_low_benchmark: 4, growth_low_benchmark: 4.25, approval_low_benchmark: 4.5, ideal_low_benchmark: 4.75, subcategory: subcategory)
  #   survey_item1 = create(:survey_item, measure: measure1)
  #   create(:survey_item_response, survey_item: survey_item1, academic_year: academic_year, school: school, likert_score: 1)
  #   create(:survey_item_response, survey_item: survey_item1, academic_year: academic_year, school: school, likert_score: 5)

  #   measure2 = create(:measure, watch_low_benchmark: 1.25, growth_low_benchmark: 1.5, approval_low_benchmark: 1.75, ideal_low_benchmark: 2.0, subcategory: subcategory)
  #   survey_item2 = create(:survey_item, measure: measure2)
  #   create(:survey_item_response, survey_item: survey_item2, academic_year: academic_year, school: school, likert_score: 1)
  #   create(:survey_item_response, survey_item: survey_item2, academic_year: academic_year, school: school, likert_score: 5)

  #   create_survey_item_responses_for_different_years_and_schools(survey_item1)

  #   return SubcategoryPresenter.new(subcategory: subcategory, academic_year: academic_year, school: school)
  # end
  let(:scale) do
    Scale.new(
      watch_low_benchmark: 1.5,
      growth_low_benchmark: 2.5,
      approval_low_benchmark: 3.5,
      ideal_low_benchmark: 4.5,
    )
  end
  let(:score) { 3 }


  let(:gauge_presenter) { GaugePresenter.new(scale: scale, score: score) }

  it 'returns the key benchmark percentage for the gauge' do
    expect(gauge_presenter.key_benchmark_percentage).to eq 0.625
  end

  context 'when the given score is in the Warning zone for the given scale' do
    let(:score) { 1 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Warning'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-warning'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.0
    end
  end

  context 'when the given score is in the Watch zone for the given scale' do
    let(:score) { 2 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Watch'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-watch'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.25
    end
  end

  context 'when the given score is in the Growth zone for the given scale' do
    let(:score) { 3 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Growth'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-growth'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.5
    end
  end

  context 'when the given score is in the Approval zone for the given scale' do
    let(:score) { 4 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Approval'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-approval'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.75
    end
  end

  context 'when the given score is in the Ideal zone for the given scale' do
    let(:score) { 5 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Ideal'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-ideal'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 1.0
    end
  end

end
