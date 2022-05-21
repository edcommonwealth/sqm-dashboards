require 'rails_helper'
include VarianceHelper

describe 'overview/_variance_chart.html.erb' do
  before do
    @academic_year = create(:academic_year)
    @district = create(:district)
    @school = create(:school)
  end

  context 'When there are scores to show' do
    subject { Nokogiri::HTML(rendered) }

    let(:survey_items1) { [create(:student_survey_item)] }
    let(:survey_items2) { [create(:student_survey_item)] }
    let(:higher_scoring_measure) do
      measure = create(:measure)
      create(:scale, measure:, survey_items: survey_items1)
      measure
    end

    let(:lower_scoring_measure) do
      measure = create(:measure)
      create(:scale, measure:, survey_items: survey_items2)
      measure
    end

    before :each do
      presenters = [
        VarianceChartRowPresenter.new(measure: lower_scoring_measure, score: Score.new(1)),
        VarianceChartRowPresenter.new(measure: higher_scoring_measure, score: Score.new(5))
      ]

      render partial: 'variance_chart', locals: { presenters: }
    end

    it 'displays higher scoring measures above lower scoring measures' do
      measure_row_bars = subject.css('rect.measure-row-bar')

      higher_scoring_measure_index = measure_row_bars.find_index do |bar|
        bar['data-for-measure-id'] == higher_scoring_measure.measure_id
      end
      lower_scoring_measure_index = measure_row_bars.find_index do |bar|
        bar['data-for-measure-id'] == lower_scoring_measure.measure_id
      end

      expect(higher_scoring_measure_index).to be < lower_scoring_measure_index
    end
  end

  context 'When there are no scores to show for any measures' do
    before :each do
      measure_lacking_score = create(:measure)
      another_measure_lacking_score = create(:measure)
      presenters = [
        VarianceChartRowPresenter.new(measure: measure_lacking_score, score: Score.new(nil)),
        VarianceChartRowPresenter.new(measure: another_measure_lacking_score, score: Score.new(nil))
      ]

      render partial: 'variance_chart', locals: { presenters: }
    end

    it "displays the text 'insufficient data' for an empty dataset" do
      expect(rendered).to have_text 'Insufficient data'
    end

    it "does not display the partial data text: 'The following measures are not displayed due to limited availability of school admin data and/or low survey response rates:' " do
      expect(rendered).not_to have_text 'The following measures are not displayed due to limited availability of school admin data and/or low survey response rates:'
    end
  end
end
