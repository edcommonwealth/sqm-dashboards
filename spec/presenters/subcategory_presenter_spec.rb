require "rails_helper"

describe SubcategoryPresenter do
  let(:academic_year) { create(:academic_year, range: "1989-90") }
  let(:school) { create(:school, name: "Best School") }
  let(:worst_school) { create(:school, name: "Worst School", dese_id: 2) }
  let(:subcategory) do
    create(:subcategory, name: "A great subcategory", subcategory_id: "A", description: "A great description")
  end
  let(:measure_of_only_admin_data) { create(:measure, subcategory:) }
  let(:scale_of_only_admin_data) { create(:scale, measure: measure_of_only_admin_data) }
  let(:admin_data_item_1) { create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: false) }
  let(:admin_data_item_2) { create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: false) }
  let(:subcategory_presenter) do
    measure1 = create(:measure, subcategory:)
    teacher_scale_1 = create(:teacher_scale, measure: measure1)
    student_scale_1 = create(:student_scale, measure: measure1)
    survey_item1 = create(:teacher_survey_item, scale: teacher_scale_1, watch_low_benchmark: 4, growth_low_benchmark: 4.25,
                                                approval_low_benchmark: 4.5, ideal_low_benchmark: 4.75)
    survey_item2 = create(:student_survey_item, scale: student_scale_1, watch_low_benchmark: 4, growth_low_benchmark: 4.25,
                                                approval_low_benchmark: 4.5, ideal_low_benchmark: 4.75)
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item1,
                                                                                       academic_year:, school:, likert_score: 1)
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item1,
                                                                                       academic_year:, school:, likert_score: 5)
    create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD / 2, survey_item: survey_item2,
                                                                                           academic_year:, school:, likert_score: 3)
    create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD / 2, survey_item: survey_item2,
                                                                                           academic_year:, school:, likert_score: 3)

    measure2 = create(:measure, subcategory:)
    teacher_scale_2 = create(:teacher_scale, measure: measure2)
    student_scale_2 = create(:student_scale, measure: measure2)

    survey_item3 = create(:teacher_survey_item, scale: teacher_scale_2, watch_low_benchmark: 1.25,
                                                growth_low_benchmark: 1.5, approval_low_benchmark: 1.75, ideal_low_benchmark: 2.0)
    survey_item4 = create(:student_survey_item, scale: student_scale_2, watch_low_benchmark: 1.25,
                                                growth_low_benchmark: 1.5, approval_low_benchmark: 1.75, ideal_low_benchmark: 2.0)
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item3,
                                                                                       academic_year:, school:, likert_score: 1)
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item3,
                                                                                       academic_year:, school:, likert_score: 5)
    create_list(:survey_item_response, 10, survey_item: survey_item4,
                                           academic_year:, school:, likert_score: 3, grade: 1)

    # Adding responses corresponding to different years and schools should not pollute the score calculations
    create_survey_item_responses_for_different_years_and_schools(survey_item1)

    return SubcategoryPresenter.new(subcategory:, academic_year:, school:)
  end

  before do
    create(:respondent, school:, academic_year:, one: 40)
  end

  it "returns the name of the subcategory" do
    expect(subcategory_presenter.name).to eq "A great subcategory"
  end

  it "returns the description of the subcategory" do
    expect(subcategory_presenter.description).to eq "A great description"
  end

  it "returns the id of the subcategory" do
    expect(subcategory_presenter.id).to eq "A"
  end

  it "returns a gauge presenter responsible for the aggregate admin data and survey item response likert scores" do
    expect(subcategory_presenter.gauge_presenter.title).to eq "Growth"
  end

  it "returns the student response rate" do
    expect(subcategory_presenter.student_response_rate).to eq "25%"
  end

  it "returns the teacher response rate" do
    expect(subcategory_presenter.teacher_response_rate).to eq "50%"
  end

  it "returns the admin collection rate" do
    expect(subcategory_presenter.admin_collection_rate).to eq %w[N A]
  end

  it "creates a measure presenter for each measure in a subcategory" do
    expect(subcategory_presenter.measure_presenters.count).to eq subcategory.measures.count
  end

  def create_survey_item_responses_for_different_years_and_schools(survey_item)
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item:,
                                                                                       school: worst_school, likert_score: 1)
    create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item:,
                                                                                       academic_year: AcademicYear.create(range: "2000-01"), likert_score: 1)
  end

  context "When there are admin data items" do
    context "and the school is not a high school" do
      context "and the measure does not include high-school-only admin data items" do
        before do
          measure_of_only_admin_data
          scale_of_only_admin_data
          admin_data_item_1
          admin_data_item_2
        end
        context "and there are no admin data values in the database" do
          it "returns the admin collection rate" do
            expect(subcategory_presenter.admin_collection_rate).to eq [0, 2]
          end
        end
        context "and there are admin data values present in the database " do
          before do
            create(:admin_data_value, admin_data_item: admin_data_item_1, school:, academic_year:)
            create(:admin_data_value, admin_data_item: admin_data_item_2, school:, academic_year:)
          end
          it "returns the admin collection rate" do
            expect(subcategory_presenter.admin_collection_rate).to eq [2, 2]
          end
        end
      end

      context "and the measure includes high-school-only items" do
        before do
          measure_of_only_admin_data = create(:measure, subcategory:)
          scale_of_only_admin_data = create(:scale, measure: measure_of_only_admin_data)
          create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: true)
          create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: true)
        end
        it "returns the admin collection rate" do
          expect(subcategory_presenter.admin_collection_rate).to eq %w[N A]
        end
      end
    end

    context "and the school is a high school" do
      context "and the measure does not include high-school-only admin data items" do
        before do
          school.is_hs = true
          school.save
          measure_of_only_admin_data = create(:measure, subcategory:)
          scale_of_only_admin_data = create(:scale, measure: measure_of_only_admin_data)
          create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: false)
          create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: false)
        end
        it "returns the admin collection rate" do
          expect(subcategory_presenter.admin_collection_rate).to eq [0, 2]
        end
      end

      context "and the measure includes high-school-only items" do
        before do
          school.is_hs = true
          school.save
          measure_of_only_admin_data = create(:measure, subcategory:)
          scale_of_only_admin_data = create(:scale, measure: measure_of_only_admin_data)
          create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: true)
          create(:admin_data_item, scale: scale_of_only_admin_data, hs_only_item: true)
        end
        it "returns the admin collection rate" do
          expect(subcategory_presenter.admin_collection_rate).to eq [0, 2]
        end
      end
    end
  end
end
