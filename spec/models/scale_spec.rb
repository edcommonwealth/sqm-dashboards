require 'rails_helper'

RSpec.describe Scale, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:scale) { create(:scale) }
  before do
    create(:survey, school:, academic_year:)
  end

  describe '.score' do
    let(:teacher_survey_item_1) { create(:teacher_survey_item, scale:) }
    let(:teacher_survey_item_2) { create(:teacher_survey_item, scale:) }
    let(:teacher_survey_item_3) { create(:teacher_survey_item, scale:) }
    let(:student_survey_item_1) { create(:student_survey_item, scale:) }

    context 'when only teacher survey items exist' do
      before :each do
        create(:survey_item_response,
               survey_item: teacher_survey_item_1, academic_year:, school:, likert_score: 3)
        create(:survey_item_response,
               survey_item: teacher_survey_item_2, academic_year:, school:, likert_score: 4)
        create(:survey_item_response,
               survey_item: teacher_survey_item_3, academic_year:, school:, likert_score: 5)
      end
      it 'returns the average of the likert scores of the survey items' do
        expect(scale.score(school:, academic_year:)).to eq 4
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

    context 'when both teacher and student survey items exist' do
      before :each do
      create(:survey_item_response,
             survey_item: teacher_survey_item_1, academic_year:, school:, likert_score: 3)
      create(:survey_item_response,
             survey_item: teacher_survey_item_2, academic_year:, school:, likert_score: 4)
      create(:survey_item_response,
             survey_item: teacher_survey_item_3, academic_year:, school:, likert_score: 5)
      end
      context 'but no survey item responses are linked to student survey items' do
        before :each do
          student_survey_item_1
        end

        it 'returns a score that only averages teacher survey items' do
          expect(scale.score(school:, academic_year:)).to eq 4
        end
      end

      context 'and some survey item responses exist for a student survey item' do
        before :each do
          create(:survey_item_response,
                 survey_item: student_survey_item_1, academic_year:, school:, likert_score: 2)
        end
        it 'returns a score that gives equal weight to student and teacher survey items' do
          expect(scale.score(school:, academic_year:)).to eq 3
        end
      end
    end
  end
end
