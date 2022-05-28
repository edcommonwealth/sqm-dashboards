require 'rails_helper'
include AnalyzeHelper

describe 'analyze/index' do
  subject { Nokogiri::HTML(rendered) }
  let(:category) { create(:category) }
  let(:subcategory) { create(:subcategory, category:) }

  let(:support_for_teaching) do
    measure = create(:measure, name: 'Support For Teaching Development & Growth', measure_id: '1A-I', subcategory:)
    scale = create(:scale, measure:)
    create(:student_survey_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  let(:effective_leadership) do
    measure = create(:measure, name: 'Effective Leadership', measure_id: '1A-II', subcategory:)
    scale = create(:scale, measure:)
    create(:teacher_survey_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  let(:professional_qualifications) do
    measure = create(:measure, name: 'Professional Qualifications', measure_id: '1A-III', subcategory:)
    scale = create(:scale, measure:)
    create(:admin_data_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end
  let(:academic_year) { create(:academic_year) }

  before :each do
    # assign :category_presenters, []
    # assign :grouped_bar_column_presenters, grouped_bar_column_presenters
    assign :academic_year, academic_year
    # assign :academic_years, [academic_year]
    assign :district, create(:district)
    assign :school, create(:school)
    assign :category, category
    assign :categories, [category]
    assign :subcategory, subcategory
    assign :measures, [support_for_teaching, effective_leadership, professional_qualifications]

    render
  end

  context 'when all the presenters have a nil score' do
    # let(:grouped_bar_column_presenters) do
    #   measure = create(:measure, name: 'Display Me', measure_id: 'display-me')
    #   scale = create(:scale, measure:)
    #   create(:student_survey_item,
    #          scale:,
    #          watch_low_benchmark: 1.5,
    #          growth_low_benchmark: 2.5,
    #          approval_low_benchmark: 3.5,
    #          ideal_low_benchmark: 4.5)
    #   [
    #     GroupedBarColumnPresenter.new(measure:,
    #                                   score: Score.new(rand))
    #   ]
    # end

    it 'displays a set of grouped bars for each presenter' do
      displayed_variance_rows = subject.css('[data-for-measure-id]')
      expect(displayed_variance_rows.count).to eq 9
      expect(displayed_variance_rows.first.attribute('data-for-measure-id').value).to eq '1A-I'

      displayed_variance_labels = subject.css('[data-grouped-bar-label]')
      expect(displayed_variance_labels.count).to eq 9
      expect(displayed_variance_labels.first.inner_text).to include 'All Students'
      expect(displayed_variance_labels.last.inner_text).to include 'All Survey Data'
    end

    it 'displays all measures for the first subcategory' do
      expect(rendered).to have_text '1A-I'
      expect(rendered).to have_text '1A-II'
      expect(rendered).to have_text '1A-III'
    end

    it 'displays user interface controls' do
      expect(subject).to have_text 'Focus Area'
      expect(subject).to have_css '#select-category'
    end
  end
end
