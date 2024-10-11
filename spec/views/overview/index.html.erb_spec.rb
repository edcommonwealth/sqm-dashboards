require "rails_helper"
include VarianceHelper

describe "overview/index" do
  subject { Nokogiri::HTML(rendered) }

  let(:support_for_teaching) do
    measure = create(:measure, name: "Support For Teaching Development & Growth", measure_id: "1")
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
    measure = create(:measure, name: "Effective Leadership", measure_id: "2")
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
    measure = create(:measure, name: "Professional Qualifications", measure_id: "3")
    scale = create(:scale, measure:)
    create(:admin_data_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    measure
  end

  let(:variance_chart_row_presenters) do
    measure = create(:measure, name: "Display Me", measure_id: "display-me")
    scale = create(:scale, measure:)
    create(:student_survey_item,
           scale:,
           watch_low_benchmark: 1.5,
           growth_low_benchmark: 2.5,
           approval_low_benchmark: 3.5,
           ideal_low_benchmark: 4.5)
    [
      Overview::VarianceChartRowPresenter.new(construct: measure,
                                              score: Score.new(average: rand))
    ]
  end
  context "when some presenters have a nil score" do
    let(:variance_chart_row_presenters) do
      [
        Overview::VarianceChartRowPresenter.new(construct: support_for_teaching, score: Score.new),
        Overview::VarianceChartRowPresenter.new(construct: effective_leadership, score: Score.new(average: rand)),
        Overview::VarianceChartRowPresenter.new(construct: professional_qualifications, score: Score.new)
      ]
    end

    before :each do
      assign :category_presenters, []
      assign :variance_chart_row_presenters, variance_chart_row_presenters
      @academic_year = create(:academic_year)
      assign :academic_years, [@academic_year]
      @district = create(:district)
      @school = create(:school)
      assign :page,
             Overview::OverviewPresenter.new(params: { view: "student" }, school: @school,
                                             academic_year: @academic_year)
      @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                   academic_year: @academic_year)
      @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                   academic_year: @academic_year)

      Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
      ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                           student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

      render
    end

    it "displays a note detailing which measures have insufficient responses for the given school & academic year" do
      expect(rendered).to match %r{Note: The following measures are not displayed due to limited availability of school data and/or low survey response rates: Support For Teaching Development &amp; Growth; Professional Qualifications.}
    end

    it "displays a variance row and label only those presenters for which the score is not nil" do
      displayed_variance_rows = subject.css("[data-for-measure-id]")
      expect(displayed_variance_rows.count).to eq 1
      expect(displayed_variance_rows.first.attribute("data-for-measure-id").value).to eq "2"

      displayed_variance_labels = subject.css("[data-variance-row-label]")
      expect(displayed_variance_labels.count).to eq 1
      expect(displayed_variance_labels.first.inner_text).to include "Effective Leadership"
    end
  end

  context "when all the presenters have a non-nil score" do
    before :each do
      assign :category_presenters, []
      assign :variance_chart_row_presenters, variance_chart_row_presenters
      @academic_year = create(:academic_year)
      assign :academic_years, [@academic_year]
      @district = create(:district)
      @school = create(:school)
      assign :page,
             Overview::OverviewPresenter.new(params: { view: "student" }, school: @school,
                                             academic_year: @academic_year)
      @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                   academic_year: @academic_year)
      @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                   academic_year: @academic_year)

      Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
      ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                           student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

      render
    end

    it "does not display a note detailing which measures have insufficient responses for the given school & academic year" do
      expect(rendered).not_to match %r{Note: The following measures are not displayed due to limited availability of school data and/or low survey response rates}
    end

    it "displays a variance row for each presenter" do
      displayed_variance_rows = subject.css("[data-for-measure-id]")
      expect(displayed_variance_rows.count).to eq 1
      expect(displayed_variance_rows.first.attribute("data-for-measure-id").value).to eq "display-me"

      displayed_variance_labels = subject.css("[data-variance-row-label]")
      expect(displayed_variance_labels.count).to eq 1
      expect(displayed_variance_labels.first.inner_text).to include "Display Me"
    end
  end

  context "when the default view is shown" do
    context "and there are NOT enough parent survey items to show data" do
      before :each do
        assign :category_presenters, []
        assign :variance_chart_row_presenters, variance_chart_row_presenters
        @academic_year = create(:academic_year)
        assign :academic_years, [@academic_year]
        @district = create(:district)
        @school = create(:school)
        assign :page,
               Overview::OverviewPresenter.new(params: { view: "student" }, school: @school,
                                               academic_year: @academic_year)
        @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                     academic_year: @academic_year)
        @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                     academic_year: @academic_year)

        Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
        ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                             student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

        assign(:category_presenters, Category.all.map { |category| CategoryPresenter.new(category:) })
        render
      end
      it "shows the view with the students & teachers button active" do
        expect(subject.css("input[id='student_and_teacher_btn'][checked='checked']").count).to eq 0
        expect(subject.css("input[id='parent_btn'][checked='checked']").count).to eq 0
      end
    end
  end

  context "when the default view is shown" do
    context "and there are enough parent survey items to show data" do
      before :each do
        assign :category_presenters, []
        assign :variance_chart_row_presenters, variance_chart_row_presenters
        @academic_year = create(:academic_year)
        assign :academic_years, [@academic_year]
        @district = create(:district)
        @school = create(:school)
        assign :page,
               Overview::OverviewPresenter.new(params: { view: "student" }, school: @school,
                                               academic_year: @academic_year)
        @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                     academic_year: @academic_year)
        @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                     academic_year: @academic_year)

        Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
        ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                             student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

        parent_scale = create(:parent_scale)
        parent_survey_item = create(:parent_survey_item, scale: parent_scale)

        create_list(:survey_item_response, 10, survey_item: parent_survey_item, school: @school,
                                               academic_year: @academic_year, likert_score: 3)
        assign(:category_presenters, Category.all.map { |category| CategoryPresenter.new(category:) })
        render
      end
      it "shows the view with the students & teachers button active" do
        expect(subject.css("input[id='student_and_teacher_btn'][checked='checked']").count).to eq 1
        expect(subject.css("input[id='parent_btn'][checked='checked']").count).to eq 0
      end
    end
  end

  context "when the parent view is shown" do
    context "and there is NOT enough parent data to show" do
      before :each do
        assign :category_presenters, []
        assign :variance_chart_row_presenters, variance_chart_row_presenters
        @academic_year = create(:academic_year)
        assign :academic_years, [@academic_year]
        @district = create(:district)
        @school = create(:school)
        assign :page,
               Overview::ParentOverviewPresenter.new(params: { view: "parent" }, school: @school,
                                                     academic_year: @academic_year)
        @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                     academic_year: @academic_year)
        @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                     academic_year: @academic_year)

        Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
        ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                             student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

        assign(:category_presenters, Category.all.map { |category| CategoryPresenter.new(category:) })
        render
      end
      it "shows the view with the parent button active" do
        expect(subject.css("input[id='parent_btn'][checked='checked']").count).to eq 0
        expect(subject.css("input[id='student_and_teacher_btn'][checked='checked']").count).to eq 0
      end
    end
  end
  context "when the parent view is shown" do
    context "and there is enough parent data to show" do
      before :each do
        assign :category_presenters, []
        assign :variance_chart_row_presenters, variance_chart_row_presenters
        @academic_year = create(:academic_year)
        assign :academic_years, [@academic_year]
        @district = create(:district)
        @school = create(:school)
        assign :page,
               Overview::ParentOverviewPresenter.new(params: { view: "parent" }, school: @school,
                                                     academic_year: @academic_year)
        @student_response_rate_presenter = ResponseRatePresenter.new(focus: :student, school: @school,
                                                                     academic_year: @academic_year)
        @teacher_response_rate_presenter = ResponseRatePresenter.new(focus: :teacher, school: @school,
                                                                     academic_year: @academic_year)

        Respondent.create!(school: @school, academic_year: @academic_year, total_students: 40, total_teachers: 40)
        ResponseRate.create!(subcategory: Subcategory.first, school: @school, academic_year: @academic_year,
                             student_response_rate: 100, teacher_response_rate: 100, meets_student_threshold: true, meets_teacher_threshold: true)

        parent_scale = create(:parent_scale)
        parent_survey_item = create(:parent_survey_item, scale: parent_scale)

        create_list(:survey_item_response, 10, survey_item: parent_survey_item, school: @school,
                                               academic_year: @academic_year, likert_score: 3)
        assign(:category_presenters, Category.all.map { |category| CategoryPresenter.new(category:) })
        render
      end
      it "shows the view with the parent button active" do
        expect(subject.css("input[id='parent_btn'][checked='checked']").count).to eq 1
        expect(subject.css("input[id='student_and_teacher_btn'][checked='checked']").count).to eq 0
      end
    end
  end
end
