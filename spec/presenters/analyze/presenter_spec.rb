require "rails_helper"

describe Analyze::Presenter do
  let(:category) { create(:category, category_id: "1", name: "first category") }
  let(:category_2) { create(:category, category_id: "2", name: "second category") }
  let(:wrong_category) { create(:category, category_id: "999", name: "wrong category") }
  let(:subcategory) { create(:subcategory, subcategory_id: "1A", name: "first subcategory", category:) }
  let(:subcategory_2) { create(:subcategory, subcategory_id: "2A", name: "second subcategory", category: category_2) }
  let(:wrong_subcategory) do
    create(:subcategory, subcategory_id: "99A", name: "wrong subcategory", category: wrong_category)
  end
  let(:measure) { create(:measure, measure_id: "1A-i", name: "first measure", subcategory:) }
  let(:measure_2) { create(:measure, measure_id: "2A-i", name: "second measure", subcategory: subcategory_2) }
  let(:wrong_measure) do
    create(:wrong_measure, measure_id: "99A", name: "wrong measure", subcategory: wrong_subcategory)
  end
  let(:scale) { create(:student_scale, measure:) }
  let(:parent_scale) { create(:parent_scale, measure:) }
  let(:survey_item) { create(:student_survey_item, scale:) }
  let(:parent_survey_item) { create(:parent_survey_item, scale: parent_scale) }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:ay_2021_22) { create(:academic_year, range: "2021-22") }
  let(:ay_2022_23) { create(:academic_year, range: "2022-23") }
  let(:wrong_ay) { create(:academic_year, range: "9999-99") }
  let(:black) { create(:race, designation: "black", qualtrics_code: 1) }
  let(:white) { create(:race, designation: "white", qualtrics_code: 2) }
  let(:wrong_race) { create(:race, designation: "wrong race", qualtrics_code: 9999) }
  let(:female) { create(:gender, designation: "female", qualtrics_code: 1) }
  let(:male) { create(:gender, designation: "male", qualtrics_code: 2) }
  let(:wrong_gender) { create(:gender, designation: "wrong_gender", qualtrics_code: 2) }

  context ".category" do
    before :each do
      category
      category_2
      wrong_category
    end
    context "when a category is provided in the params hash" do
      it "returns the category with the given id" do
        params = { category: "1" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.category).to eq category

        params = { category: "2" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.category).to eq category_2
      end
    end

    context "when no category is provided in the params hash" do
      it "returns the first category" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.category).to eq category
      end
    end

    context "when a category that doesnt exist in the database is passed" do
      it "returns the first category" do
        params = { category: "4" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.category).to eq category
      end
    end
  end

  context ".categories" do
    it "returns all categories" do
      params = {}
      presenter = Analyze::Presenter.new(params:, school:, academic_year:)
      expect(presenter.categories).to eq Category.all.order(:category_id)
    end
  end

  context ".subcategory" do
    before :each do
      category
      category_2
      wrong_category
      subcategory
      subcategory_2
      wrong_subcategory
    end
    context "when a subcategory is provided in the params hash" do
      it "returns the subcategory with the given id" do
        params = { subcategory: "1A" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.subcategory).to eq subcategory

        params = { subcategory: "2A" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.subcategory).to eq subcategory_2
      end
    end

    context "when no subcategory is provided in the params hash" do
      it "returns the first subcategory" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.subcategory).to eq subcategory
      end
    end

    context "when a subcategory that doesnt exist in the database is passed" do
      it "returns the first subcategory" do
        params = { subcategory: "4A" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.subcategory).to eq subcategory
      end
    end
  end

  context ".subcategories" do
    before :each do
      category
      wrong_category
      subcategory
      wrong_subcategory
    end
    it "returns all subcategories for a given category" do
      params = { category: "1" }
      presenter = Analyze::Presenter.new(params:, school:, academic_year:)
      expect(presenter.subcategories).to eq category.subcategories.all.order(:subcategory_id)
    end
  end

  context ".measures" do
    before :each do
      category
      subcategory
      measure
    end

    it "returns all measures for a given subcategory" do
      params = { category: "1" }
      presenter = Analyze::Presenter.new(params:, school:, academic_year:)
      expect(presenter.measures).to eq category.subcategories.flat_map(&:measures)
    end
  end

  context ".academic_years" do
    before :each do
      ay_2021_22
      ay_2022_23
    end

    it "returns all academic years" do
      params = {}
      presenter = Analyze::Presenter.new(params:, school:, academic_year:)
      expect(presenter.academic_years).to eq AcademicYear.all.order(:range)
    end
  end

  context ".selected_academic_years" do
    before :each do
      ay_2021_22
      ay_2022_23
      wrong_ay
    end
    context "when no academic years are provided in the params hash" do
      it "returns an empty array if no params are provided" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_academic_years).to eq []
      end
    end
    context "when a single academic year is provided in the params hash" do
      it "returns the academic year with the given id" do
        params = { academic_years: "2021-22" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_academic_years).to eq [AcademicYear.find_by_range("2021-22")]

        params = { academic_years: "2022-23" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_academic_years).to eq [AcademicYear.find_by_range("2022-23")]
      end
    end

    context "when multiple academic years are provided in the params hash" do
      it "returns the academic year with the given ids" do
        params = { academic_year1: "2021-22", academic_year2: "2022-23" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_academic_years).to eq [AcademicYear.find_by_range("2021-22"),
                                                         AcademicYear.find_by_range("2022-23")]
      end
    end
  end

  context ".races" do
    before :each do
      black
      white
      wrong_race
    end

    it "returns all races" do
      params = {}
      presenter = Analyze::Presenter.new(params:, school:, academic_year:)
      expect(presenter.races).to eq Race.all.order(designation: :ASC)
    end
  end

  context ".selected_races" do
    before :each do
      black
      white
      wrong_race
    end
    context "when no races are provided in the params hash" do
      it "returns an array with all races if no params are provided" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_races).to eq presenter.races
      end
    end

    context "when one race is provided in the params hash" do
      it "returns a single race with the given slug" do
        params = { "race1-checkbox" => "white" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_races).to eq [Race.find_by_slug("white")]

        params = { "race1-checkbox" => "black" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_races).to eq [Race.find_by_slug("black")]
      end
    end

    context "when multiple races are provided in the params hash" do
      it "returns multiple races with the given slugs" do
        params = { "race1-checkbox" => "white",
                   "race2-checkbox" => "black" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_races).to eq [Race.find_by_slug("white"), Race.find_by_slug("black")]
      end
    end
  end

  context ".graph" do
    context "when no params are provided" do
      it "returns the default(first) graph object" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::AllData.new.to_s
      end
    end

    context "when a graph is provided in the params hash" do
      it "returns the graph object with the given slug" do
        params = { graph: "all_data" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::AllData.new.to_s

        params = { graph: "students-and-teachers" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::StudentsAndTeachers.new.to_s

        params = { graph: "students-by-race" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::StudentsByRace.new(races: nil).to_s

        params = { graph: "students-by-grade" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::StudentsByGrade.new(grades: nil).to_s

        params = { graph: "students-by-gender" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::StudentsByGender.new(genders: nil).to_s
      end
    end

    context "when a parameter that does not match a graph is provided" do
      it "returns the default(first) graph object" do
        params = { graph: "invalid parameter" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.graph.to_s).to eq Analyze::Graph::AllData.new.to_s
      end
    end
  end

  context ".grades" do
    before :each do
      school
      academic_year
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 1, survey_item:)
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 2, survey_item:)
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 3, survey_item:)
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 4, survey_item:)
    end

    context "when no grades are provided in the params hash" do
      it "returns the set of grades for which there are more than ten responses" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.grades).to eq [1, 2, 3, 4]
      end
    end
  end

  context ".selected_grades" do
    before :each do
      school
      academic_year
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 1, survey_item:)
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 2, survey_item:)
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 3, survey_item:)
      create_list(:survey_item_response, 20, school:, academic_year:, grade: 4, survey_item:)
    end

    context "when no grades are provided in the params hash" do
      it "returns only the set of grades selected even if other grades have sufficient responses" do
        params = { "grade1-checkbox" => "1", "grade2-checkbox" => "2", "grade3-checkbox" => "3" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_grades).to eq [1, 2, 3]
      end
    end
  end

  context ".selected_genders" do
    before :each do
      male
      female
      wrong_gender
    end
    context "when no parameters are provided" do
      it "returns all genders" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_genders).to eq Gender.all.order(designation: :ASC)
      end
    end

    context "when a single gender is provided in the params hash" do
      it "returns the gender with the given designation" do
        params = { "gender1-checkbox" => "female" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_genders).to eq [Gender.find_by_designation("female")]

        params = { "gender1-checkbox" => "male" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_genders).to eq [Gender.find_by_designation("male")]
      end
    end

    context "when multiple genders are provided in the params hash" do
      it "returns multilple genders with the given designations" do
        params = { "gender1-checkbox" => "female", "gender2-checkbox" => "male" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.selected_genders).to eq [Gender.find_by_designation("female"),
                                                  Gender.find_by_designation("male")]
      end
    end
  end

  context ".genders" do
    before :each do
      female
      male
    end

    it "returns all genders" do
      params = {}
      presenter = Analyze::Presenter.new(params:, school:, academic_year:)
      expect(presenter.genders).to eq Gender.all.order(designation: :ASC)
    end
  end

  context ".group" do
    context "when no parameters are provided" do
      it "returns no groups when no params are defined" do
        presenter = Analyze::Presenter.new(params: {}, school:, academic_year:)
        expect(presenter.groups).to eq []
      end
    end

    context "when a group is provided in the params hash" do
      it "returns the group with the given slug" do
        params = { group: "gender", graph: "students-by-gender" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.group.slug).to eq "gender"

        params = { group: "grade", graph: "students-by-grade" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.group.slug).to eq "grade"

        params = { group: "race", graph: "students-by-race" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.group.slug).to eq "race"

        params = { group: "income", graph: "students-by-income" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.group.slug).to eq "income"
      end
    end

    context "when a parameter that does not match a group is provided" do
      it "returns nil when invalid parameters are given" do
        params = { group: "invalid group", graph: "invalid graph" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.group).to eq nil
      end
    end
  end

  context ".slice" do
    context "when no parameters are provided" do
      it "returns the first item in the list of slices" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "all-data"
      end
    end

    context "when the graph is all-data" do
      it "returns the slice with the given slug" do
        params = { graph: "all-data" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "all-data"
      end
    end

    context "when the graph is 'students-and-teachers'" do
      it "returns the slice with the given slug" do
        params = { graph: "students-and-teachers" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-and-teachers"
      end
    end

    context "when the graph is 'parents-by-language'" do
      before :each do
        parent_survey_item
        parent_scale
        measure
      end
      it "returns the slice with the given slug" do
        params = { graph: "parents-by-language" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "parents-by-group"
        expect(presenter.requested_graphs).to eq "parents-by-language"
        expect(presenter.show_secondary_graph?(measure:)).to eq false
        expect(presenter.show_scale_level_graphs?(measure:)).to eq true
        expect(presenter.secondary_graph.class.to_s).to eq "Analyze::Graph::AllParent"
        expect(presenter.secondary_graph.slug).to eq "all-parent"
      end
    end

    context "when the graph is of a disaggregation group" do
      it "returns the slice with the given slug" do
        params = { graph: "students-by-ell" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-by-group"

        params = { graph: "students-by-gender" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-by-group"

        params = { graph: "students-by-grade" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-by-group"

        params = { graph: "students-by-income" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-by-group"

        params = { graph: "students-by-race" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-by-group"

        params = { graph: "students-by-sped" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "students-by-group"
      end
    end
  end

  context ".source" do
    context "when no parameters are provided" do
      it "returns the first item in the list of sources" do
        params = {}
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "all-data"
      end
    end

    context "when a graph is provided in the params hash" do
      it "returns the source with the given slug" do
        params = { graph: "all-data" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.source.slug).to eq "all-data"

        params = { graph: "students-and-teachers" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.source.slug).to eq "survey-data-only"
      end
    end

    context "when a parameter that does not match a graph is provided" do
      it "returns the first item in the list of sources" do
        params = { graph: "invalid-source" }
        presenter = Analyze::Presenter.new(params:, school:, academic_year:)
        expect(presenter.slice.slug).to eq "all-data"
      end
    end
  end
end
