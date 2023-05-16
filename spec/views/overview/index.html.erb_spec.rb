require 'rails_helper'
include VarianceHelper

describe 'overview/index' do
  subject { Nokogiri::HTML(rendered) }

  let(:support_for_teaching) do
    measure = create(:measure, name: 'Support For Teaching Development & Growth', measure_id: '1')
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
    measure = create(:measure, name: 'Effective Leadership', measure_id: '2')
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
    measure = create(:measure, name: 'Professional Qualifications', measure_id: '3')
    scale = create(:scale, measure:)
    create(:admin_data_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  before :each do
    assign :category_presenters, []
    assign :variance_chart_row_presenters, variance_chart_row_presenters
    @academic_year = create(:academic_year)
    assign :academic_years, [@academic_year]
    @district = create(:district)
    @school = create(:school)
    @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                 academic_year: @academic_year)
    @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                 academic_year: @academic_year)

    Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
    ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                         student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

    render
  end

  context 'when some presenters have a nil score' do
    let(:variance_chart_row_presenters) do
      [
        VarianceChartRowPresenter.new(measure: support_for_teaching, score: Score.new),
        VarianceChartRowPresenter.new(measure: effective_leadership, score: Score.new(average: rand)),
        VarianceChartRowPresenter.new(measure: professional_qualifications, score: Score.new)
      ]
    end

    it 'displays a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).to match %r{Note: The following measures are not displayed due to limited availability of school data and/or low survey response rates: Support For Teaching Development &amp; Growth; Professional Qualifications.}
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
      scale = create(:scale, measure:)
      create(:student_survey_item,
             scale:,
             watch_low_benchmark: 1.5,
             growth_low_benchmark: 2.5,
             approval_low_benchmark: 3.5,
             ideal_low_benchmark: 4.5)
      [
        VarianceChartRowPresenter.new(measure:,
                                      score: Score.new(average: rand))
      ]
    end

    it 'does not display a note detailing which measures have insufficient responses for the given school & academic year' do
      expect(rendered).not_to match %r{Note: The following measures are not displayed due to limited availability of school data and/or low survey response rates}
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
