require 'rails_helper'

describe 'dashboard/index.html.erb' do

  let(:support_for_teaching) { create(:measure, name: 'Support For Teaching Development & Growth') }
  let(:effective_leadership) { create(:measure, name: 'Effective Leadership') }
  let(:professional_qualifications) { create(:measure, name: 'Professional Qualifications') }

  before :each do
    assign :category_presenters, []
    assign :measure_graph_row_presenters, measure_graph_row_presenters

    render
  end

  context 'when there are measures for which, in the given academic year, the school has insufficient responses' do
    let(:measure_graph_row_presenters) {
      [
        MeasureGraphRowPresenter.new(measure: support_for_teaching, score: 0, sufficient_data: false),
        MeasureGraphRowPresenter.new(measure: create(:measure), score: 0, sufficient_data: true),
        MeasureGraphRowPresenter.new(measure: effective_leadership, score: 0, sufficient_data: false),
        MeasureGraphRowPresenter.new(measure: professional_qualifications, score: 0, sufficient_data: false)
      ]
    }

    it 'displays a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).to match /Note: The following measures are not displayed due to limited availability of school admin data and\/or low survey response rates: Support For Teaching Development &amp; Growth; Effective Leadership; Professional Qualifications./
    end
  end

  context 'when there are no measures for which, in the given academic year, the school has insufficient responses' do
    let(:measure_graph_row_presenters) {
      [
        MeasureGraphRowPresenter.new(measure: create(:measure), score: 0, sufficient_data: true)
      ]
    }

    it 'does not display a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).not_to match /Note: The following measures are not displayed due to limited availability of school admin data and\/or low survey response rates/
    end
  end
end
