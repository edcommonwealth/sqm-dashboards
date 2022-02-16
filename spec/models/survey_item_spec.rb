require 'rails_helper'
RSpec.describe SurveyItem, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:scale) { create(:scale) }

  describe '.score' do
    let(:teacher_survey_item) { create(:teacher_survey_item, scale:) }

    before :each do
      create(:survey_item_response,
             survey_item: teacher_survey_item, academic_year:, school:, likert_score: 3)
      create(:survey_item_response,
             survey_item: teacher_survey_item, academic_year:, school:, likert_score: 4)
      create(:survey_item_response,
             survey_item: teacher_survey_item, academic_year:, school:, likert_score: 5)
    end

    it 'returns the average of the likert scores of the survey items' do
      expect(teacher_survey_item.score(school:, academic_year:)).to eq 4
    end

    context 'when other scales exist' do
      before :each do
        create(:survey_item_response,
               academic_year:, school:, likert_score: 1)
        create(:survey_item_response,
               academic_year:, school:, likert_score: 1)
        create(:survey_item_response,
               academic_year:, school:, likert_score: 1)
      end

      it 'does not affect the score for the original scale' do
        expect(scale.score(school:, academic_year:)).to eq 4
      end
    end
  end
end
