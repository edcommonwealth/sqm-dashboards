require 'rails_helper'

describe 'overview/index.html.erb' do
  subject { Nokogiri::HTML(rendered) }

  let(:support_for_teaching) { create(:measure, name: 'Support For Teaching Development & Growth') }
  let(:effective_leadership) { create(:measure, name: 'Effective Leadership') }
  let(:professional_qualifications) { create(:measure, name: 'Professional Qualifications') }

  before :each do
    assign :category_presenters, []
    assign :variance_chart_row_presenters, variance_chart_row_presenters

    render
  end

  context 'when some presenters have a nil score' do
    let(:variance_chart_row_presenters) {
      [
        VarianceChartRowPresenter.new(measure: support_for_teaching, score: Score.new),
        VarianceChartRowPresenter.new(measure: create(:measure, name: 'Should Be Displayed', measure_id: 'should-be-displayed'), score: Score.new(rand)),
        VarianceChartRowPresenter.new(measure: effective_leadership, score: Score.new),
        VarianceChartRowPresenter.new(measure: professional_qualifications, score: Score.new)
      ]
    }

    it 'displays a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).to match /Note: The following measures are not displayed due to limited availability of school admin data and\/or low survey response rates: Support For Teaching Development &amp; Growth; Effective Leadership; Professional Qualifications./
    end

    it 'displays a variance row and label only those presenters for which the score is not nil' do
      displayed_variance_rows = subject.css('[data-for-measure-id]')
      expect(displayed_variance_rows.count).to eq 1
      expect(displayed_variance_rows.first.attribute('data-for-measure-id').value).to eq 'should-be-displayed'

      displayed_variance_labels = subject.css('[data-variance-row-label]')
      expect(displayed_variance_labels.count).to eq 1
      expect(displayed_variance_labels.first.inner_text).to include 'Should Be Displayed'
    end
  end

  context 'when all the presenters have a non-nil score' do
    let(:variance_chart_row_presenters) {
      [
        VarianceChartRowPresenter.new(measure: create(:measure, name: 'Display Me', measure_id: 'display-me'), score: Score.new(rand))
      ]
    }

    it 'does not display a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).not_to match /Note: The following measures are not displayed due to limited availability of school admin data and\/or low survey response rates/
    end

    it 'displays a variance row for each presenter' do
      displayed_variance_rows = subject.css('[data-for-measure-id]')
      expect(displayed_variance_rows.count).to eq 1
      expect(displayed_variance_rows.first.attribute('data-for-measure-id').value).to eq 'display-me'

      displayed_variance_labels = subject.css('[data-variance-row-label]')
      expect(displayed_variance_labels.count).to eq 1
      expect(displayed_variance_labels.first.inner_text).to include 'Display Me'
    end
  end
end
