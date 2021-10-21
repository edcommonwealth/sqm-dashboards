require 'rails_helper'

describe SurveyItemResponse, type: :model do

  describe '.sufficient_data?' do
    let(:measure) { create(:measure) }
    let(:school) { create(:school) }
    let(:ay) { create(:academic_year) }

    context 'when the measure includes only teacher data' do
      let(:teacher_survey_item_1) { create(:survey_item, survey_item_id: 't-question-1', measure: measure) }

      context 'and there is sufficient teacher data' do
        before :each do
          SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is truthy' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_truthy
        end
      end

      context 'and there is insufficient teacher data' do
        before :each do
          (SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1).times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is falsey' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_falsey
        end
      end
    end

    context 'when the measure includes only student data' do
      let(:student_survey_item_1) { create(:survey_item, survey_item_id: 's-question-1', measure: measure) }

      context 'and there is sufficient student data' do
        before :each do
          SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is truthy' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_truthy
        end
      end

      context 'and there insufficient student data' do
        before :each do
          (SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1).times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is falsey' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_falsey
        end
      end
    end

    context 'when the measure includes both teacher and student data' do
      let(:teacher_survey_item_1) { create(:survey_item, survey_item_id: 't-question-1', measure: measure) }
      let(:student_survey_item_1) { create(:survey_item, survey_item_id: 's-question-1', measure: measure) }

      context 'and there is sufficient teacher data and sufficient student data' do
        before :each do
          SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          end
          SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is truthy' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_truthy
        end
      end

      context 'and there is sufficient teacher data and insufficient student data' do
        before :each do
          SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          end
          (SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1).times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is falsey' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_falsey
        end
      end

      context 'and there is insufficient teacher data and sufficient student data' do
        before :each do
          (SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1).times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          end
          SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is falsey' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_falsey
        end
      end

      context 'and there is insufficient teacher data and insufficient student data' do
        before :each do
          (SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1).times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          end
          (SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1).times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school)
          end
        end

        it 'is falsey' do
          expect(SurveyItemResponse.sufficient_data?(measure: measure, academic_year: ay, school: school)).to be_falsey
        end
      end
    end
  end
end
