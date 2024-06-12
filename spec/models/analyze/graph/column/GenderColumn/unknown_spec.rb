require "rails_helper"

RSpec.describe Analyze::Graph::Column::GenderColumn::Unknown, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:measure) { create(:measure) }
  let(:academic_years) { [academic_year] }
  let(:position) { 0 }
  let(:number_of_columns) { 1 }
  let(:gender) { create(:gender, qualtrics_code: 99) }

  let(:subcategory) { create(:subcategory, subcategory_id: "1A") }
  let(:measure) { create(:measure, measure_id: "1A-iii", subcategory:) }
  let(:scale) { create(:student_scale, measure:) }
  let(:survey_item) { create(:student_survey_item, scale:) }
  let(:teacher_scale) { create(:teacher_scale, measure:) }
  let(:teacher_survey_item) { create(:teacher_survey_item, scale:) }

  context "when no teacher responses exist" do
    context "when there are insufficient unknown students" do
      it "reports a score of 3 when the average is 3" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).score(academic_year).average).to eq(nil)
      end
      it "reports insufficient data" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).sufficient_student_responses?(academic_year:)).to eq(false)
      end
    end
    context "when there are sufficient unknown students" do
      before :each do
        create_list(:survey_item_response, 10, school:, academic_year:, gender:, survey_item:)
      end
      it "reports a score of 3 when the average is 3" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).score(academic_year).average).to eq(3)
      end

      it "reports sufficient data" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).sufficient_student_responses?(academic_year:)).to eq(true)
      end
    end
  end

  context "when teacher responses exist" do
    before :each do
      create_list(:survey_item_response, 10, school:, academic_year:, survey_item: teacher_survey_item, likert_score: 5)
    end

    context "when there are insufficient unknown students" do
      it "reports a score of 3 when the average is 3" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).score(academic_year).average).to eq(nil)
      end
      it "reports insufficient data" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).sufficient_student_responses?(academic_year:)).to eq(false)
      end
    end
    context "when there are sufficient unknown students" do
      before :each do
        create_list(:survey_item_response, 10, school:, academic_year:, gender:, survey_item:)
      end
      it "reports a score of 3 when the average is 3" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).score(academic_year).average).to eq(3)
      end

      it "reports sufficient data" do
        expect(Analyze::Graph::Column::GenderColumn::Unknown.new(school:, academic_years:, position:, measure:,
                                                                 number_of_columns:).sufficient_student_responses?(academic_year:)).to eq(true)
      end
    end
  end
end

