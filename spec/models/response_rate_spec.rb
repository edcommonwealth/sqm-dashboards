require 'rails_helper'

describe ResponseRate, type: :model do
  let(:school) { create(:school) }
  let(:ay) { create(:academic_year) }
  let(:survey_respondents) do
    create(:respondent, school: school, total_students: SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                        total_teachers: SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, academic_year: ay)
  end

  describe StudentResponseRate do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory: subcategory) }
    let(:sufficient_measure_2) { create(:measure, subcategory: subcategory) }
    let(:insufficient_measure) { create(:measure, subcategory: subcategory) }
    let(:sufficient_teacher_survey_item) { create(:teacher_survey_item, measure: sufficient_measure_1) }
    let(:sufficient_student_survey_item_1) { create(:student_survey_item, measure: sufficient_measure_1) }
    let(:insufficient_teacher_survey_item) { create(:teacher_survey_item, measure: insufficient_measure) }
    let(:sufficient_student_survey_item_2) { create(:student_survey_item, measure: sufficient_measure_2) }
    let(:insufficient_student_survey_item) { create(:student_survey_item, measure: insufficient_measure) }

    before :each do
      survey_respondents
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item,
                                                                                         academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                         academic_year: ay, school: school, likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD + 1, survey_item: sufficient_student_survey_item_2,
                                                                                             academic_year: ay, school: school, likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                  survey_item: insufficient_teacher_survey_item, academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                  survey_item: insufficient_student_survey_item, academic_year: ay, school: school, likert_score: 1)
    end

    context 'when the average number of student responses per question in a subcategory is equal to the student response threshold' do
      it 'returns 100 percent' do
        expect(StudentResponseRate.new(subcategory: subcategory, school: school,
                                academic_year: ay).rate).to eq 100
      end
    end
  end

  describe TeacherResponseRate do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory: subcategory) }
    let(:sufficient_measure_2) { create(:measure, subcategory: subcategory) }
    let(:insufficient_measure) { create(:measure, subcategory: subcategory) }
    let(:sufficient_teacher_survey_item_1) { create(:teacher_survey_item, measure: sufficient_measure_1) }
    let(:sufficient_teacher_survey_item_2) { create(:teacher_survey_item, measure: sufficient_measure_1) }
    let(:sufficient_teacher_survey_item_3) { create(:teacher_survey_item, measure: sufficient_measure_1) }
    let(:sufficient_student_survey_item_1) { create(:student_survey_item, measure: sufficient_measure_1) }
    let(:insufficient_teacher_survey_item) { create(:teacher_survey_item, measure: insufficient_measure) }
    let(:insufficient_student_survey_item) { create(:student_survey_item, measure: insufficient_measure) }

    before :each do
      survey_respondents
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item_1,
                                                                                         academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD + 1, survey_item: sufficient_teacher_survey_item_2,
                                                                                             academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                         academic_year: ay, school: school, likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                  survey_item: insufficient_teacher_survey_item, academic_year: ay, school: school, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                  survey_item: insufficient_student_survey_item, academic_year: ay, school: school, likert_score: 1)
    end

    context 'when the average number of teacher responses per question in a subcategory is equal to the total possible responses' do
      it 'returns 100 percent' do
        expect(TeacherResponseRate.new(subcategory: subcategory, school: school,
                                academic_year: ay).rate).to eq 100
      end
    end

    context 'when the average number of teacher responses is 77.9, the response rate averages up to 78 percent' do
      before do
        create_list(:survey_item_response, 2, survey_item: sufficient_teacher_survey_item_3,
                                              academic_year: ay, school: school, likert_score: 1)
      end
      it 'returns 10 percent' do
        expect(TeacherResponseRate.new(subcategory: subcategory, school: school,
                                academic_year: ay).rate).to eq 78
      end
    end

    context 'when the average number of teacher responses is greater than the total possible responses' do
      before do
        create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD + 1, survey_item: sufficient_teacher_survey_item_3,
                                                                                               academic_year: ay, school: school, likert_score: 1)
      end
      it 'returns 100 percent' do
        expect(TeacherResponseRate.new(subcategory: subcategory, school: school,
                                academic_year: ay).rate).to eq 100
      end
    end
  end
end
