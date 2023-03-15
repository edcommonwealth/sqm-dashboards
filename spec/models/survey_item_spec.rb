require 'rails_helper'
RSpec.describe SurveyItem, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:scale) { create(:scale) }
  before :each do
    create(:survey, school:, academic_year:)
  end

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

  describe '.survey_type_for_grade' do
    let(:early_education_survey_item1) { create(:early_education_survey_item, scale:) }
    context 'when no responses exist' do
      it 'it returns back a regular survey' do
        expect(SurveyItem.survey_type_for_grade(school, academic_year, 0)).to eq :regular
      end
    end

    context 'when some responses exist' do
      context 'and the responses are only within the set of early education survey items' do
        before :each do
          create(:survey_item_response, survey_item: early_education_survey_item1, school:, academic_year:, grade: 0)
        end

        it 'reports the survey type as early education' do
          expect(SurveyItem.survey_type_for_grade(school, academic_year, 0)).to eq :early_education
        end
      end

      context 'when there are responses for both early education and regular survey items' do
        before :each do
          create(:survey_item_response, school:, academic_year:, grade: 0)
        end
        it 'reports the survey type as regular' do
          expect(SurveyItem.survey_type_for_grade(school, academic_year, 0)).to eq :regular
        end
      end
    end
  end
end
