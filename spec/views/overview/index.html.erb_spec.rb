require 'rails_helper'

describe 'overview/index' do
  subject { Nokogiri::HTML(rendered) }

  let(:support_for_teaching) do
    measure = create(:measure, name: 'Support For Teaching Development & Growth', measure_id: '1')
    create(:student_survey_item,
           measure: measure,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  let(:effective_leadership) do
    measure = create(:measure, name: 'Effective Leadership', measure_id: '2')
    create(:teacher_survey_item,
           measure: measure,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  let(:professional_qualifications) do
    measure = create(:measure, name: 'Professional Qualifications', measure_id: '3')
    create(:admin_data_item,
           measure: measure,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  before :each do
    assign :category_presenters, []
    assign :variance_chart_row_presenters, variance_chart_row_presenters

    render
  end

  context 'when some presenters have a nil score' do
    let(:variance_chart_row_presenters) do
      [
        VarianceChartRowPresenter.new(measure: support_for_teaching, score: Score.new),
        VarianceChartRowPresenter.new(measure: effective_leadership, score: Score.new(rand)),
        VarianceChartRowPresenter.new(measure: professional_qualifications, score: Score.new)
      ]
    end

    it 'displays a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).to match %r{Note: The following measures are not displayed due to limited availability of school admin data and/or low survey response rates: Support For Teaching Development &amp; Growth; Professional Qualifications.}
    end

    it 'displays a variance row and label only those presenters for which the score is not nil' do
      displayed_variance_rows = subject.css('[data-for-measure-id]')
      expect(displayed_variance_rows.count).to eq 1
      expect(displayed_variance_rows.first.attribute('data-for-measure-id').value).to eq '2'

      displayed_variance_labels = subject.css('[data-variance-row-label]')
      expect(displayed_variance_labels.count).to eq 1
      expect(displayed_variance_labels.first.inner_text).to include 'Effective Leadership'
    end
  end

  context 'when all the presenters have a non-nil score' do
    let(:variance_chart_row_presenters) do
      measure = create(:measure, name: 'Display Me', measure_id: 'display-me')
      create(:student_survey_item,
             measure: measure,
             watch_low_benchmark: 1.5,
             growth_low_benchmark: 2.5,
             approval_low_benchmark: 3.5,
             ideal_low_benchmark: 4.5)
      [
        VarianceChartRowPresenter.new(measure: measure,
                                      score: Score.new(rand))
      ]
    end

    it 'does not display a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).not_to match %r{Note: The following measures are not displayed due to limited availability of school admin data and/or low survey response rates}
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