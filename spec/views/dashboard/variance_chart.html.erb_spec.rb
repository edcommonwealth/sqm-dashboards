require 'rails_helper'

describe 'dashboard/_variance_chart.html.erb' do
  subject { Nokogiri::HTML(rendered) }

  let(:higher_scoring_measure) { create(:measure) }
  let(:lower_scoring_measure) { create(:measure) }

  before :each do
    presenters = [
      VarianceChartRowPresenter.new(measure: lower_scoring_measure, score: 1),
      VarianceChartRowPresenter.new(measure: higher_scoring_measure, score: 5)
    ]

    render partial: 'variance_chart', locals: { presenters: presenters }
  end

  it 'displays higher scoring measures above lower scoring measures' do
    measure_row_bars = subject.css("rect.measure-row-bar")

    higher_scoring_measure_index = measure_row_bars.find_index { |bar| bar['data-for-measure-id'] == higher_scoring_measure.measure_id }
    lower_scoring_measure_index = measure_row_bars.find_index { |bar| bar['data-for-measure-id'] == lower_scoring_measure.measure_id }

    expect(higher_scoring_measure_index).to be < lower_scoring_measure_index
  end
end
