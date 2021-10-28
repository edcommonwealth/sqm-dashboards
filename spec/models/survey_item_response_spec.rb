require 'rails_helper'

describe SurveyItemResponse, type: :model do
  let(:school) { create(:school) }
  let(:ay) { create(:academic_year) }

  describe '.score_for_measure' do
    let(:measure) { create(:measure) }

    context 'when the measure includes only teacher data' do
      let(:teacher_survey_item_1) { create(:survey_item, survey_item_id: 't-question-1', measure: measure) }
      let(:teacher_survey_item_2) { create(:survey_item, survey_item_id: 't-question-2', measure: measure) }
      let(:teacher_survey_item_3) { create(:survey_item, survey_item_id: 't-question-3', measure: measure) }

      context "and the number of responses for each of the measure's survey items meets the teacher threshold of 17" do
        before :each do
          17.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 3)
          end
          17.times do
            create(:survey_item_response, survey_item: teacher_survey_item_2, academic_year: ay, school: school, likert_score: 4)
          end
          17.times do
            create(:survey_item_response, survey_item: teacher_survey_item_3, academic_year: ay, school: school, likert_score: 5)
          end
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to eq 4
        end
      end

      context "and the average number of responses across the measure's survey items meets the teacher threshold of 17" do
        before :each do
          19.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 3)
          end
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_2, academic_year: ay, school: school, likert_score: 4)
          end
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_3, academic_year: ay, school: school, likert_score: 5)
          end
        end

        it 'returns the average of the likert scores of the survey items' do
          average_score = 3.941
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_within(0.001).of(average_score)
        end
      end

      context "and none of the measure's survey items meets the teacher threshold of 17" do
        before :each do
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: rand)
          end
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_2, academic_year: ay, school: school, likert_score: rand)
          end
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_3, academic_year: ay, school: school, likert_score: rand)
          end
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
        end
      end

      context "and the average number of responses across the measure's survey items does not meet the teacher threshold of 17" do
        before :each do
          18.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: rand)
          end
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_2, academic_year: ay, school: school, likert_score: rand)
          end
          16.times do
            create(:survey_item_response, survey_item: teacher_survey_item_3, academic_year: ay, school: school, likert_score: rand)
          end
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
        end
      end
    end

    context 'when the measure includes only student data' do
      let(:student_survey_item_1) { create(:survey_item, survey_item_id: 's-question-1', measure: measure) }
      let(:student_survey_item_2) { create(:survey_item, survey_item_id: 's-question-2', measure: measure) }
      let(:student_survey_item_3) { create(:survey_item, survey_item_id: 's-question-3', measure: measure) }

      context "and the number of responses for each of the measure's survey items meets the student threshold of 196" do
        before :each do
          196.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 3)
          end
          196.times do
            create(:survey_item_response, survey_item: student_survey_item_2, academic_year: ay, school: school, likert_score: 4)
          end
          196.times do
            create(:survey_item_response, survey_item: student_survey_item_3, academic_year: ay, school: school, likert_score: 5)
          end
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to eq 4
        end
      end

      context "and the average number of responses across the measure's survey items meets the student threshold of 196" do
        before :each do
          200.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 3)
          end
          195.times do
            create(:survey_item_response, survey_item: student_survey_item_2, academic_year: ay, school: school, likert_score: 4)
          end
          193.times do
            create(:survey_item_response, survey_item: student_survey_item_3, academic_year: ay, school: school, likert_score: 5)
          end
        end

        it 'returns the average of the likert scores of the survey items' do
          average_score = 3.988
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_within(0.001).of(average_score)
        end
      end

      context "and none of the measure's survey items meets the student threshold of 196" do
        before :each do
          195.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: rand)
          end
          195.times do
            create(:survey_item_response, survey_item: student_survey_item_2, academic_year: ay, school: school, likert_score: rand)
          end
          195.times do
            create(:survey_item_response, survey_item: student_survey_item_3, academic_year: ay, school: school, likert_score: rand)
          end
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
        end
      end

      context "and the average number of responses across the measure's survey items does not meet the student threshold of 196" do
        before :each do
          200.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: rand)
          end
          196.times do
            create(:survey_item_response, survey_item: student_survey_item_2, academic_year: ay, school: school, likert_score: rand)
          end
          191.times do
            create(:survey_item_response, survey_item: student_survey_item_3, academic_year: ay, school: school, likert_score: rand)
          end
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
        end
      end
    end

    context 'when the measure includes both teacher and student data' do
      let(:teacher_survey_item_1) { create(:survey_item, survey_item_id: 't-question-1', measure: measure) }
      let(:student_survey_item_1) { create(:survey_item, survey_item_id: 's-question-1', measure: measure) }

      context 'and there is sufficient teacher data and sufficient student data' do
        before :each do
          SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 5)
          end
          SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD.times do
            create(:survey_item_response, survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 5)
          end
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to eq 5
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

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
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

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
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

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school, academic_year: ay)).to be_nil
        end
      end
    end
  end

  describe '.score_for_subcategory' do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory: subcategory) }
    let(:sufficient_measure_2) { create(:measure, subcategory: subcategory) }
    let(:insufficient_measure) { create(:measure, subcategory: subcategory) }
    let(:sufficient_teacher_survey_item) { create(:survey_item, survey_item_id: 't-question-1', measure: sufficient_measure_1) }
    let(:insufficient_teacher_survey_item) { create(:survey_item, survey_item_id: 't-question-2', measure: insufficient_measure) }
    let(:sufficient_student_survey_item) { create(:survey_item, survey_item_id: 's-question-1', measure: sufficient_measure_2) }
    let(:insufficient_student_survey_item) { create(:survey_item, survey_item_id: 's-question-2', measure: insufficient_measure) }

    before :each do
      [SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD].max.times do
        create(:survey_item_response, survey_item: sufficient_teacher_survey_item, academic_year: ay, school: school, likert_score: 1)
        create(:survey_item_response, survey_item: sufficient_student_survey_item, academic_year: ay, school: school, likert_score: 4)
      end
      (SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1).times do
        create(:survey_item_response, survey_item: insufficient_teacher_survey_item, academic_year: ay, school: school, likert_score: 1)
      end
      (SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1).times do
        create(:survey_item_response, survey_item: insufficient_student_survey_item, academic_year: ay, school: school, likert_score: 1)
      end
    end

    it 'returns the average score of all survey item responses for measures meeting their respective thresholds' do
      expect(SurveyItemResponse.score_for_subcategory(subcategory: subcategory, school: school, academic_year: ay)).to eq 2.5
    end
  end
end
