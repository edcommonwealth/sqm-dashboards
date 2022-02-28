require 'rails_helper'

RSpec.describe Subcategory, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:subcategory) { create(:subcategory) }
  let(:measure_1) { create(:measure, subcategory:) }
  let(:teacher_scale) { create(:teacher_scale, measure: measure_1) }
  let(:measure_2) { create(:measure, subcategory:) }
  let(:student_scale) { create(:student_scale, measure: measure_2) }
  before do
    create(:respondent, school:, academic_year:)
    create(:survey, school:, academic_year:)
  end

  describe '.score' do
    let(:teacher_survey_item_1) { create(:teacher_survey_item, scale: teacher_scale) }
    let(:teacher_survey_item_2) { create(:teacher_survey_item, scale: teacher_scale) }
    let(:teacher_survey_item_3) { create(:teacher_survey_item, scale: teacher_scale) }
    let(:student_survey_item_1) { create(:student_survey_item, scale: student_scale) }
    let(:student_survey_item_2) { create(:student_survey_item, scale: student_scale) }
    let(:student_survey_item_3) { create(:student_survey_item, scale: student_scale) }
    let(:student_survey_item_4) { create(:student_survey_item, scale: student_scale) }
    let(:student_survey_item_5) { create(:student_survey_item, scale: student_scale) }

    before :each do
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                  survey_item: teacher_survey_item_1,  academic_year:, school:, likert_score: 2)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                  survey_item: teacher_survey_item_2,  academic_year:, school:, likert_score: 3)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                  survey_item: teacher_survey_item_3,  academic_year:, school:, likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                  survey_item: student_survey_item_1,  academic_year:, school:, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                  survey_item: student_survey_item_2,  academic_year:, school:, likert_score: 2)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                  survey_item: student_survey_item_3,  academic_year:, school:, likert_score: 3)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                  survey_item: student_survey_item_4,  academic_year:, school:, likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                  survey_item: student_survey_item_5,  academic_year:, school:, likert_score: 5)
    end

    it 'returns the average of the likert scores of the measures' do
      expect(subcategory.score(school:, academic_year:)).to eq 3
    end

    context 'when other subcategories exist' do
      before :each do
        create(:survey_item_response,
               academic_year:, school:, likert_score: 1)
        create(:survey_item_response,
               academic_year:, school:, likert_score: 1)
        create(:survey_item_response,
               academic_year:, school:, likert_score: 1)
      end

      it 'does not affect the score for the original scale' do
        expect(subcategory.score(school:, academic_year:)).to eq 3
      end
    end
  end
end
