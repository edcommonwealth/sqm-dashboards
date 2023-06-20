require "rails_helper"
include AnalyzeHelper
include Analyze::Graph
describe "analyze/index" do
  subject { Nokogiri::HTML(rendered) }
  let(:category) { create(:category) }
  let(:subcategory) { create(:subcategory, category:) }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:races) do
    DemographicLoader.load_data(filepath: "spec/fixtures/sample_demographics.csv")
    Race.all
  end
  let(:background) { BackgroundPresenter.new(num_of_columns: graph.columns.count) }

  let(:support_for_teaching) do
    measure = create(:measure, name: "Support For Teaching Development & Growth", measure_id: "1A-I", subcategory:)
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
    measure = create(:measure, name: "Effective Leadership", measure_id: "1A-II", subcategory:)
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
    measure = create(:measure, name: "Professional Qualifications", measure_id: "1A-III", subcategory:)
    scale = create(:scale, measure:)
    create(:admin_data_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  let(:genders) do
    DemographicLoader.load_data(filepath: "spec/fixtures/sample_demographics.csv")
    Gender.all
  end

  let(:respondent) { create(:respondent, school:, academic_year:) }

  before :each do
    races
    category
    subcategory
    support_for_teaching
    effective_leadership
    professional_qualifications
    respondent
    assign :academic_year, academic_year
    assign :district, create(:district)
    assign :school, school
    assign :presenter,
           Analyze::Presenter.new(school:, academic_year:,
                                  params: { category: category.category_id, subcategory: subcategory.subcategory_id, races: "american-indian-or-alaskan-native,asian-or-pacific-islander,black-or-african-american,hispanic-or-latinx,middle-eastern,multiracial,race-ethnicity-not-listed,white-or-caucasian", source: "survey-data-only", slice: "students-and-teachers", group: "race", graph: "students-by-race" })
    assign :background, BackgroundPresenter.new(num_of_columns: 4)
  end
  context "when all the presenters have a nil score" do
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

    it "displays a set of grouped bars for each presenter" do
      displayed_variance_columns = subject.css(".grouped-bar-column")
      expect(displayed_variance_columns.count).to eq 27

      displayed_variance_rows = subject.css("[data-for-measure-id]")
      expect(displayed_variance_rows.first.attribute("data-for-measure-id").value).to eq "1A-I"

      displayed_academic_years = subject.css("[data-for-academic-year]")
      expect(displayed_academic_years.count).to eq 0

      displayed_variance_labels = subject.css("[data-grouped-bar-label]")

      expect(displayed_variance_labels.count).to eq 39
      expect(displayed_variance_labels.first.inner_text).to include "American"
      expect(displayed_variance_labels.text).to include "Indian"
      expect(displayed_variance_labels.text).to include "Asian"
      expect(displayed_variance_labels.text).to include "Black"
      expect(displayed_variance_labels.text).to include "White"
      expect(displayed_variance_labels.text).to include "Hispanic"
      expect(displayed_variance_labels.text).to include "Middle"
      expect(displayed_variance_labels.text).to include "Eastern"
      expect(displayed_variance_labels.text).to include "Multiracial"
      expect(displayed_variance_labels.text).to include "Not"
      expect(displayed_variance_labels.text).to include "Listed"
    end

    it "displays all measures for the first subcategory" do
      expect(rendered).to have_text "1A-I"
      expect(rendered).to have_text "1A-II"
      expect(rendered).to have_text "1A-III"
    end

    it "displays user interface controls" do
      expect(subject).to have_text "Focus Area"
      expect(subject).to have_css "#select-category"
      expect(subject).to have_css "#select-subcategory"
      expect(subject).to have_css "##{academic_year.range}"
    end

    it "displays disabled checkboxes for years that dont have data" do
      year_checkbox = subject.css("##{academic_year.range}").first
      expect(year_checkbox.name).to eq "input"
      expect(academic_year.range).to eq "2050-51"
      expect(year_checkbox).to have_attribute "disabled"
    end

    it "displays a radio box selector for each type of data filter" do
      expect(subject).to have_css "#students-and-teachers"
      expect(subject).to have_css "#students-by-group"
    end

    it "displays a checkbox for each race designation" do
      race_slugs = %w[race-american-indian-or-alaskan-native race-asian-or-pacific-islander race-black-or-african-american
                      race-hispanic-or-latinx race-middle-eastern race-multiracial race-race-ethnicity-not-listed race-white-or-caucasian]
      race_slugs.each do |slug|
        expect(subject).to have_css("//input[@type='checkbox'][@id='#{slug}']")
      end
    end
  end

  context "when presenters have a displayable score" do
    before do
      render
    end

    context "when displaying a student and teacher graph" do
    end
  end
end
