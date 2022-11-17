require 'rails_helper'
include AnalyzeHelper
include Analyze::Graph
describe 'analyze/index' do
  subject { Nokogiri::HTML(rendered) }
  let(:category) { create(:category) }
  let(:subcategory) { create(:subcategory, category:) }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:races) do
    DemographicLoader.load_data(filepath: 'spec/fixtures/sample_demographics.csv')
    Race.all
  end
  let(:graph) { StudentsAndTeachers.new }
  let(:graphs) do
    [StudentsAndTeachers.new, StudentsByRace.new(races:)]
  end
  let(:background) { BackgroundPresenter.new(num_of_columns: graph.columns.count) }
  let(:selected_races) { races }

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

  let(:sources) do
    [Analyze::Source::SurveyData.new(slices:)]
  end

  let(:slices) do
    students_and_teachers = Analyze::Slice::StudentsAndTeachers.new
    students_by_group = Analyze::Slice::StudentsByGroup.new(races:, grades:)
    [students_and_teachers, students_by_group]
  end

  let(:slice) do
    slices.first
  end

  let(:groups) do
    [Analyze::Group::Race.new, Analyze::Group::Grade.new]
  end

  let(:group) do
    groups.first
  end

  let(:grades) do
    (1..12).to_a
  end

  let(:genders) do
    DemographicLoader.load_data(filepath: 'spec/fixtures/sample_demographics.csv')
    Gender.all
  end

  let(:selected_genders) do
    genders
  end

  let(:selected_grades) do
    grades
  end

  before :each do
    assign :races, races
    assign :selected_races, selected_races
    assign :graph, graph
    assign :graphs, graphs
    assign :background, background
    assign :academic_year, academic_year
    assign :available_academic_years, [academic_year]
    assign :selected_academic_years, [academic_year]
    assign :district, create(:district)
    assign :school, school
    assign :category, category
    assign :categories, [category]
    assign :subcategory, subcategory
    assign :subcategories, category.subcategories
    assign :measures, [support_for_teaching, effective_leadership, professional_qualifications]
    assign :sources, sources
    assign :source, sources.first
    assign :groups, groups
    assign :group, group
    assign :slice, slice
    assign :grades, grades
    assign :selected_grades, selected_grades
    assign :genders, genders
    assign :selected_genders, selected_genders
    create(:respondent, school:, academic_year:)
    create(:survey, school:, academic_year:)
  end
  context 'when all the presenters have a nil score' do
    before do
      render
    end
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
    #                                   score: Score.new(average: rand))
    #   ]
    # end

    it 'displays a set of grouped bars for each presenter' do
      displayed_variance_columns = subject.css('.grouped-bar-column')
      expect(displayed_variance_columns.count).to eq 9

      displayed_variance_rows = subject.css('[data-for-measure-id]')
      expect(displayed_variance_rows.first.attribute('data-for-measure-id').value).to eq '1A-I'

      displayed_academic_years = subject.css('[data-for-academic-year]')
      expect(displayed_academic_years.count).to eq 0

      displayed_variance_labels = subject.css('[data-grouped-bar-label]')
      expect(displayed_variance_labels.count).to eq 18
      expect(displayed_variance_labels.first.inner_text).to include 'All'
      expect(displayed_variance_labels[1].inner_text).to include 'Students'
      expect(displayed_variance_labels.last.inner_text).to include 'Data'
    end

    it 'displays all measures for the first subcategory' do
      expect(rendered).to have_text '1A-I'
      expect(rendered).to have_text '1A-II'
      expect(rendered).to have_text '1A-III'
    end

    it 'displays user interface controls' do
      expect(subject).to have_text 'Focus Area'
      expect(subject).to have_css '#select-category'
      expect(subject).to have_css '#select-subcategory'
      expect(subject).to have_css "##{academic_year.range}"
    end

    it 'displays disabled checkboxes for years that dont have data' do
      ResponseRateLoader.reset
      year_checkbox = subject.css("##{academic_year.range}").first
      expect(year_checkbox.name).to eq 'input'
      expect(academic_year.range).to eq '2050-51'
      expect(year_checkbox).to have_attribute 'disabled'
    end

    it 'displays a radio box selector for each type of data filter' do
      expect(subject).to have_css '#students-and-teachers'
      expect(subject).to have_css '#students-by-group'
    end

    it 'displays a checkbox for each race designation' do
      race_slugs = %w[american-indian-or-alaskan-native asian-or-pacific-islander black-or-african-american
                      hispanic-or-latinx middle-eastern multiracial unknown white-or-caucasian]
      race_slugs.each do |slug|
        expect(subject).to have_css("//input[@type='checkbox'][@id='#{slug}']")
      end
    end
  end

  context 'when presenters have a displayable score' do
    before do
      render
    end

    context 'when displaying a student and teacher graph' do
    end
  end
end
