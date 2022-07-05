require 'rails_helper'

describe ResponseRateCalculator, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:survey) { create(:survey, school:, academic_year:) }
  let(:short_form_survey) { create(:survey, form: :short, school:, academic_year:) }
  let(:respondent) { create(:respondent, school:, academic_year:) }

  describe StudentResponseRateCalculator do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory:) }
    let(:sufficient_scale_1) { create(:scale, measure: sufficient_measure_1) }
    let(:sufficient_measure_2) { create(:measure, subcategory:) }
    let(:sufficient_scale_2) { create(:scale, measure: sufficient_measure_2) }
    let(:sufficient_teacher_survey_item) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_student_survey_item_1) { create(:student_survey_item, scale: sufficient_scale_1) }
    let(:insufficient_student_survey_item_1) { create(:student_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_student_survey_item_2) { create(:student_survey_item, scale: sufficient_scale_2) }

    context 'when a students take a regular survey' do
      context 'when the average number of student responses per question in a subcategory is equal to the student response threshold' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item,
                                                                                             academic_year:, school:, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                             academic_year:, school:, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_2,
                                                                                             academic_year:, school:, likert_score: 4)
          respondent
          survey
        end

        it 'returns a response rate equal to the response threshold' do
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to eq 25
        end
      end

      context 'when the average number of student responses per question is below the student threshold' do
        before :each do
          create_list(:survey_item_response, 1, survey_item: sufficient_student_survey_item_1,
                                                academic_year:, school:, likert_score: 4)
          create_list(:survey_item_response, 1, survey_item: sufficient_student_survey_item_2,
                                                academic_year:, school:, likert_score: 4)
          respondent
          survey
        end

        it 'reports insufficient student responses' do
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to eq 13
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).meets_student_threshold?).to eq false
        end
      end
    end

    context 'when students take the short form survey' do
      before :each do
        create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item,
                                                                                           academic_year:, school:, likert_score: 1)
        create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                           academic_year:, school:, likert_score: 4)
        create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_2,
                                                                                           academic_year:, school:, likert_score: 4)
        respondent
        short_form_survey
      end

      context 'when the average number of student responses per question in a subcategory is equal to the student response threshold' do
        before :each do
          sufficient_student_survey_item_1.update! on_short_form: true
          sufficient_student_survey_item_2.update! on_short_form: true
        end

        it 'takes into account the responses from both survey items' do
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to eq 25
        end

        context 'and only one of the survey items is on the short form' do
          before do
            sufficient_student_survey_item_2.update! on_short_form: false
          end

          it 'the response rate ignores the responses in the non-short form item' do
            expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                     academic_year:).rate).to eq 25
          end
        end
      end
    end

    context 'when the average number of teacher responses is greater than the total possible responses' do
      before do
        respondent
        survey
        create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD * 11, survey_item: sufficient_student_survey_item_2,
                                                                                                academic_year:, school:, likert_score: 1)
      end
      it 'returns 100 percent' do
        expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 100
      end
    end

    context 'when no survey information exists for that school or year' do
      it 'returns 100 percent' do
        expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 100
      end
    end

    context 'when there is an imbalance in the response rate of the student items' do
      context 'and one of the student items has no associated survey item responses' do
        before do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item,
                                                                                             academic_year:, school:, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                             academic_year:, school:, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_2,
                                                                                             academic_year:, school:, likert_score: 4)
          create(:respondent, school:, academic_year:)
          create(:survey, school:, academic_year:)
          insufficient_student_survey_item_1
        end
        it 'ignores the empty survey item and returns only the average response rate of student survey items with responses' do
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to eq 25
        end
      end
    end
  end

  describe TeacherResponseRateCalculator do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory:) }
    let(:sufficient_scale_1) { create(:scale, measure: sufficient_measure_1) }
    let(:sufficient_measure_2) { create(:measure, subcategory:) }
    let(:sufficient_scale_2) { create(:scale, measure: sufficient_measure_2) }
    let(:sufficient_teacher_survey_item_1) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_teacher_survey_item_2) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_teacher_survey_item_3) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:insufficient_teacher_survey_item_4) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_student_survey_item_1) { create(:student_survey_item, scale: sufficient_scale_1) }

    before :each do
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item_1,
                                                                                         academic_year:, school:, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item_2,
                                                                                         academic_year:, school:, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                         academic_year:, school:, likert_score: 4)
    end

    context 'when the average number of teacher responses per question in a subcategory is at the threshold' do
      before :each do
        respondent
        survey
      end
      it 'returns 25 percent' do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 25
      end
    end

    context 'when the teacher response rate is not a whole number. eg 29.166%' do
      before do
        respondent
        survey
        create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD + 1, survey_item: sufficient_teacher_survey_item_3,
                                                                                               academic_year:, school:, likert_score: 1)
      end
      it 'it will return the nearest whole number' do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 29
      end
    end

    context 'when the average number of teacher responses is greater than the total possible responses' do
      before do
        respondent
        survey
        create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD * 11, survey_item: sufficient_teacher_survey_item_3,
                                                                                                academic_year:, school:, likert_score: 1)
      end
      it 'returns 100 percent' do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 100
      end
    end

    context 'when no survey information exists for that school and academic_year' do
      it 'returns 100 percent' do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 100
      end
    end

    context 'when there is an imbalance in the response rate of the teacher items' do
      context 'and one of the teacher items has no associated survey item responses' do
        before do
          respondent
          survey
          insufficient_teacher_survey_item_4
        end
        it 'ignores the empty survey item and returns only the average response rate of teacher survey items with responses' do
          expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to eq 25
        end
      end
    end
  end
end
