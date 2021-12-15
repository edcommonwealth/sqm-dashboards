require 'rails_helper'

describe SurveyItemResponse, type: :model do
  let(:school) { create(:school) }
  let(:ay) { create(:academic_year) }

  describe '.score_for_measure' do
    let(:measure) { create(:measure) }

    context 'when the measure includes only teacher data' do
      let(:teacher_survey_item_1) { create(:teacher_survey_item, measure: measure) }
      let(:teacher_survey_item_2) { create(:teacher_survey_item, measure: measure) }
      let(:teacher_survey_item_3) { create(:teacher_survey_item, measure: measure) }

      context "and the number of responses for each of the measure's survey items meets the teacher threshold of 17" do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 3)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_2, academic_year: ay, school: school, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_3, academic_year: ay, school: school, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to eq 4
        end

        it 'affirms that the result meets the threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be true
        end
      end

      context "and the average number of responses across the measure's survey items meets the teacher threshold of 17" do
        before :each do
          create_list(:survey_item_response, 19, survey_item: teacher_survey_item_1, academic_year: ay, school: school,
                                                 likert_score: 3)
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_2, academic_year: ay, school: school,
                                                 likert_score: 4)
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_3, academic_year: ay, school: school,
                                                 likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          average_score = 3.941
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_within(0.001).of(average_score)
        end
      end

      context "and none of the measure's survey items meets the teacher threshold of 17" do
        before :each do
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_1, academic_year: ay, school: school,
                                                 likert_score: rand)
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_2, academic_year: ay, school: school,
                                                 likert_score: rand)
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_3, academic_year: ay, school: school,
                                                 likert_score: rand)
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be false
        end
      end

      context "and the average number of responses across the measure's survey items does not meet the teacher threshold of 17" do
        before :each do
          create_list(:survey_item_response, 18, survey_item: teacher_survey_item_1, academic_year: ay, school: school,
                                                 likert_score: rand)
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_2, academic_year: ay, school: school,
                                                 likert_score: rand)
          create_list(:survey_item_response, 16, survey_item: teacher_survey_item_3, academic_year: ay, school: school,
                                                 likert_score: rand)
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be false
        end
      end
    end

    context 'when the measure includes only student data' do
      let(:student_survey_item_1) { create(:student_survey_item, measure: measure) }
      let(:student_survey_item_2) { create(:student_survey_item, measure: measure) }
      let(:student_survey_item_3) { create(:student_survey_item, measure: measure) }

      context "and the number of responses for each of the measure's survey items meets the student threshold of 196" do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 3)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_2, academic_year: ay, school: school, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_3, academic_year: ay, school: school, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to eq 4
        end

        it 'affirms that the result meets the threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be true
        end
      end

      context "and the average number of responses across the measure's survey items meets the student threshold of 196" do
        before :each do
          create_list(:survey_item_response, 200, survey_item: student_survey_item_1, academic_year: ay,
                                                  school: school, likert_score: 3)
          create_list(:survey_item_response, 195, survey_item: student_survey_item_2, academic_year: ay,
                                                  school: school, likert_score: 4)
          create_list(:survey_item_response, 193, survey_item: student_survey_item_3, academic_year: ay,
                                                  school: school, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          average_score = 3.988
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_within(0.001).of(average_score)
        end
      end

      context "and none of the measure's survey items meets the student threshold of 196" do
        before :each do
          create_list(:survey_item_response, 195, survey_item: student_survey_item_1, academic_year: ay,
                                                  school: school, likert_score: rand)
          create_list(:survey_item_response, 195, survey_item: student_survey_item_2, academic_year: ay,
                                                  school: school, likert_score: rand)
          create_list(:survey_item_response, 195, survey_item: student_survey_item_3, academic_year: ay,
                                                  school: school, likert_score: rand)
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be false
        end
      end

      context "and the average number of responses across the measure's survey items does not meet the student threshold of 196" do
        before :each do
          create_list(:survey_item_response, 200, survey_item: student_survey_item_1, academic_year: ay,
                                                  school: school, likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_2, academic_year: ay, school: school, likert_score: rand)
          create_list(:survey_item_response, 191, survey_item: student_survey_item_3, academic_year: ay,
                                                  school: school, likert_score: rand)
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be false
        end
      end
    end

    context 'when the measure includes both teacher and student data' do
      let(:teacher_survey_item_1) { create(:teacher_survey_item, measure: measure) }
      let(:student_survey_item_1) { create(:student_survey_item, measure: measure) }

      context 'and there is sufficient teacher data and sufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 5)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to eq 5
        end

        it 'affirms that the result does meet the thresholds' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be true
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be true
        end
      end

      context 'and there is sufficient teacher data and insufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 5)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                      survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 1)
        end

        it 'returns the average of the likert scores of the teacher survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to eq 5
        end

        it 'affirms that the result meets the teacher threshold but not the student threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be true
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be false
        end
      end

      context 'and there is insufficient teacher data and sufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                      survey_item: teacher_survey_item_1, academic_year: ay, school: school, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year: ay, school: school, likert_score: 5)
        end

        it 'returns the average of the likert scores of the student survey items' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to eq 5
        end

        it 'affirms that the result meets the student threshold but not the teacher threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be false
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be true
        end
      end

      context 'and there is insufficient teacher data and insufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                      survey_item: teacher_survey_item_1, academic_year: ay, school: school)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                      survey_item: student_survey_item_1, academic_year: ay, school: school)
        end

        it 'returns nil' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).average).to be_nil
        end

        it 'affirms that the result does not meet either threshold' do
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_teacher_threshold?).to be false
          expect(SurveyItemResponse.score_for_measure(measure: measure, school: school,
                                                      academic_year: ay).meets_student_threshold?).to be false
        end
      end
    end
  end

  describe '.score_for_subcategory' do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory: subcategory) }
    let(:sufficient_measure_2) { create(:measure, subcategory: subcategory) }
    let(:insufficient_measure) { create(:measure, subcategory: subcategory) }
    let(:sufficient_teacher_survey_item) { create(:teacher_survey_item, measure: sufficient_measure_1) }
    let(:insufficient_teacher_survey_item) { create(:teacher_survey_item, measure: insufficient_measure) }
    let(:sufficient_student_survey_item) { create(:student_survey_item, measure: sufficient_measure_2) }
    let(:insufficient_student_survey_item) { create(:student_survey_item, measure: insufficient_measure) }

    before :each do
      largest_threshold = [SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                           SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD].max
      create_list(:survey_item_response, largest_threshold, survey_item: sufficient_teacher_survey_item,
                                                            academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, largest_threshold, survey_item: sufficient_student_survey_item,
                                                            academic_year: ay, school: school, likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                  survey_item: insufficient_teacher_survey_item, academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                  survey_item: insufficient_student_survey_item, academic_year: ay, school: school, likert_score: 1)
    end

    it 'returns the average score of all survey item responses for measures meeting their respective thresholds' do
      expect(SurveyItemResponse.score_for_subcategory(subcategory: subcategory, school: school,
                                                      academic_year: ay)).to eq 2.5
    end
  end
end
