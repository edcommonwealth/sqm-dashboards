require 'rails_helper'

describe SurveyResponsesDataLoader do
  let(:path_to_teacher_responses) { Rails.root.join('spec', 'fixtures', 'test_2020-21_teacher_survey_responses.csv') }
  let(:path_to_student_responses) { Rails.root.join('spec', 'fixtures', 'test_2020-21_student_survey_responses.csv') }
  let(:path_to_butler_student_responses) do
    Rails.root.join('spec', 'fixtures', 'test_2022-23_butler_student_survey_responses.csv')
  end

  let(:ay_2020_21) { AcademicYear.find_by_range '2020-21' }

  let(:attleboro_high_school) { School.find_by_slug 'attleboro-high-school' }
  let(:butler_middle_school) { School.find_by_slug 'butler-middle-school' }

  let(:t_pcom_q3) { SurveyItem.find_by_survey_item_id 't-pcom-q3' }
  let(:t_pcom_q2) { SurveyItem.find_by_survey_item_id 't-pcom-q2' }
  let(:s_phys_q1) { SurveyItem.find_by_survey_item_id 's-phys-q1' }
  let(:s_phys_q2) { SurveyItem.find_by_survey_item_id 's-phys-q2' }

  let(:female) { Gender.find_by_qualtrics_code 1 }
  let(:male) { Gender.find_by_qualtrics_code 2 }
  let(:another_gender) { Gender.find_by_qualtrics_code 3 }
  let(:non_binary) { Gender.find_by_qualtrics_code 4 }
  let(:unknown_gender) { Gender.find_by_qualtrics_code 99 }

  before :all do
    Rails.application.load_seed
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe 'self.load_data' do
    context 'loading teacher survey responses' do
      before :each do
        SurveyResponsesDataLoader.load_data filepath: path_to_teacher_responses
      end
      it 'ensures teacher responses load correctly' do
        assigns_academic_year_to_survey_item_responses
        assigns_school_to_the_survey_item_responses
        loads_survey_item_responses_for_a_given_survey_response
        loads_all_survey_item_responses_for_a_given_survey_item
        captures_likert_scores_for_survey_item_responses
        is_idempotent
      end
    end

    context 'student survey responses' do
      before :each do
        SurveyResponsesDataLoader.load_data filepath: path_to_student_responses
      end

      it 'ensures student responses load correctly' do
        assigns_academic_year_to_student_survey_item_responses
        assigns_school_to_student_survey_item_responses
        loads_student_survey_item_response_values
        student_survey_item_response_count_matches_expected
        captures_likert_scores_for_student_survey_item_responses
        assigns_grade_level_to_responses
        assigns_gender_to_responses
        is_idempotent_for_students
      end

      context 'when updating student survey responses from another csv file' do
        before do
          SurveyResponsesDataLoader.load_data filepath: Rails.root.join('spec', 'fixtures',
                                                                        'secondary_test_2020-21_student_survey_responses.csv')
        end
        it 'updates the likert score to the score on the new csv file' do
          s_emsa_q1 = SurveyItem.find_by_survey_item_id 's-emsa-q1'
          expect(SurveyItemResponse.where(response_id: 'student_survey_response_3',
                                          survey_item: s_emsa_q1).first.likert_score).to eq 1
          expect(SurveyItemResponse.where(response_id: 'student_survey_response_4',
                                          survey_item: s_emsa_q1).first.likert_score).to eq 1
          expect(SurveyItemResponse.where(response_id: 'student_survey_response_5',
                                          survey_item: s_emsa_q1).first.likert_score).to eq 1
        end
      end
    end

    # This file loads the seeder every time, which is slow.  Turning it off since the above checks the correct behavior and the below will obviously fail when seeding lowell data
    # context 'when using Lowell rules to skip rows in the csv file' do
    #   before :each do
    #     SurveyResponsesDataLoader.load_data filepath: path_to_student_responses,
    #                                         rules: [Rule::SkipNonLowellSchools]
    #   end

    #   it 'rejects any non-lowell school' do
    #     expect(SurveyItemResponse.where(response_id: 'student_survey_response_1').count).to eq 0
    #     expect(SurveyItemResponse.count).to eq 128
    #   end

    #   it 'loads the correct number of responses for lowell schools' do
    #     expect(SurveyItemResponse.where(response_id: 'student_survey_response_2').count).to eq 0
    #     expect(SurveyItemResponse.where(response_id: 'student_survey_response_3').count).to eq 25
    #     expect(SurveyItemResponse.where(response_id: 'student_survey_response_4').count).to eq 22
    #     expect(SurveyItemResponse.where(response_id: 'student_survey_response_5').count).to eq 27
    #   end

    #   context 'when loading 22-23 butler survey responses' do
    #     before :each do
    #       SurveyResponsesDataLoader.load_data filepath: path_to_butler_student_responses,
    #                                           rules: [Rule::SkipNonLowellSchools]
    #     end

    #     it 'loads all the responses for Butler' do
    #       expect(SurveyItemResponse.count).to eq 400
    #     end

    #     it 'blank entries for grade get loaded as nils, not zero values' do
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_1').first.grade).to eq 7
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_2').first.grade).to eq 7
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_3').first.grade).to eq 7
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_4').first.grade).to eq 5
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_5').first.grade).to eq 7
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_6').first.grade).to eq 6
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_7').first.grade).to eq nil
    #       expect(SurveyItemResponse.where(response_id: 'butler_student_survey_response_8').first.grade).to eq 0
    #     end
    #   end
    # end
  end
end

def assigns_academic_year_to_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id('teacher_survey_response_1').academic_year).to eq ay_2020_21
end

def assigns_school_to_the_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id('teacher_survey_response_1').school).to eq attleboro_high_school
end

def loads_survey_item_responses_for_a_given_survey_response
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_1').count).to eq 5
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_2').count).to eq 0
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_3').count).to eq 69
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_4').count).to eq 69
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_5').count).to eq 69
end

def loads_all_survey_item_responses_for_a_given_survey_item
  expect(SurveyItemResponse.where(survey_item: t_pcom_q2).count).to eq 3
  expect(SurveyItemResponse.where(survey_item: t_pcom_q3).count).to eq 4
end

def captures_likert_scores_for_survey_item_responses
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_1').where(survey_item: t_pcom_q2)).to be_empty
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_1').where(survey_item: t_pcom_q3).first.likert_score).to eq 3

  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_2').where(survey_item: t_pcom_q2)).to be_empty
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_2').where(survey_item: t_pcom_q3)).to be_empty

  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_3').where(survey_item: t_pcom_q2).first.likert_score).to eq 5
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_3').where(survey_item: t_pcom_q3).first.likert_score).to eq 5

  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_4').where(survey_item: t_pcom_q2).first.likert_score).to eq 4
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_4').where(survey_item: t_pcom_q3).first.likert_score).to eq 4

  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_5').where(survey_item: t_pcom_q2).first.likert_score).to eq 2
  expect(SurveyItemResponse.where(response_id: 'teacher_survey_response_5').where(survey_item: t_pcom_q3).first.likert_score).to eq 4
end

def is_idempotent
  number_of_survey_item_responses = SurveyItemResponse.count

  SurveyResponsesDataLoader.load_data filepath: path_to_teacher_responses

  expect(SurveyItemResponse.count).to eq number_of_survey_item_responses
end

def assigns_academic_year_to_student_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id('student_survey_response_3').academic_year).to eq ay_2020_21
end

def assigns_school_to_student_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id('student_survey_response_3').school).to eq butler_middle_school
end

def loads_student_survey_item_response_values
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_1').count).to eq 3
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_2').count).to eq 0
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_3').count).to eq 25
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_4').count).to eq 22
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_5').count).to eq 27
end

def student_survey_item_response_count_matches_expected
  expect(SurveyItemResponse.where(survey_item: s_phys_q1).count).to eq 6
  expect(SurveyItemResponse.where(survey_item: s_phys_q2).count).to eq 5
end

def captures_likert_scores_for_student_survey_item_responses
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_1').where(survey_item: s_phys_q1).first.likert_score).to eq 3
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_1').where(survey_item: s_phys_q2)).to be_empty

  expect(SurveyItemResponse.where(response_id: 'student_survey_response_2').where(survey_item: s_phys_q1)).to be_empty
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_2').where(survey_item: s_phys_q2)).to be_empty

  expect(SurveyItemResponse.where(response_id: 'student_survey_response_3').where(survey_item: s_phys_q1).first.likert_score).to eq 1
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_3').where(survey_item: s_phys_q2).first.likert_score).to eq 3

  expect(SurveyItemResponse.where(response_id: 'student_survey_response_4').where(survey_item: s_phys_q1).first.likert_score).to eq 1
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_4').where(survey_item: s_phys_q2).first.likert_score).to eq 1

  expect(SurveyItemResponse.where(response_id: 'student_survey_response_5').where(survey_item: s_phys_q1).first.likert_score).to eq 1
  expect(SurveyItemResponse.where(response_id: 'student_survey_response_5').where(survey_item: s_phys_q2).first.likert_score).to eq 2
end

def is_idempotent_for_students
  number_of_survey_item_responses = SurveyItemResponse.count

  SurveyResponsesDataLoader.load_data filepath: path_to_student_responses

  expect(SurveyItemResponse.count).to eq number_of_survey_item_responses
end

def assigns_grade_level_to_responses
  results = { 'student_survey_response_1' => 11,
              'student_survey_response_3' => 8,
              'student_survey_response_4' => 8,
              'student_survey_response_5' => 7,
              'student_survey_response_6' => 3,
              'student_survey_response_7' => 4 }
  results.each do |key, value|
    expect(SurveyItemResponse.where(response_id: key).all? do |response|
             response.grade == value
           end).to eq true
  end
end

def assigns_gender_to_responses
  results = { 'student_survey_response_1' => female,
              'student_survey_response_3' => male,
              'student_survey_response_4' => non_binary,
              'student_survey_response_5' => non_binary,
              'student_survey_response_6' => unknown_gender,
              'student_survey_response_7' => unknown_gender }

  results.each do |key, value|
    expect(SurveyItemResponse.where(response_id: key).first.gender).to eq value
  end
end
