require 'rails_helper'

describe SurveyResponsesDataLoader do
  let(:path_to_csv) { Rails.root.join('spec', 'fixtures', 'test_2020-21_teacher_survey_responses.csv') }

  let(:ay_2020_21) { AcademicYear.find_by_range '2020-21' }

  let(:attleboro_high_school) { School.find_by_slug 'attleboro-high-school' }

  let(:t_pcom_q3) { SurveyItem.find_by_survey_item_id 't-pcom-q3' }
  let(:t_pcom_q2) { SurveyItem.find_by_survey_item_id 't-pcom-q2' }

  describe 'self.load_data' do
    before :each do
      SurveyResponsesDataLoader.load_data filepath: path_to_csv
    end

    it 'loads the csv data into the database' do
      expect(SurveyItemResponse.count).to be > 0
    end

    it 'assigns the academic year to the survey item responses' do
      expect(SurveyItemResponse.first.academic_year).to eq ay_2020_21
    end

    it 'assigns the school to the survey item responses' do
      expect(SurveyItemResponse.first.school).to eq attleboro_high_school
    end

    it 'loads all the survey item responses for a given survey response' do
      expect(SurveyItemResponse.where(response_id: 'survey_response_1').count).to eq 5
      expect(SurveyItemResponse.where(response_id: 'survey_response_2').count).to eq 0
      expect(SurveyItemResponse.where(response_id: 'survey_response_3').count).to eq 69
    end

    it 'loads all the survey item responses for a given survey item' do
      expect(SurveyItemResponse.where(survey_item: t_pcom_q2).count).to eq 3
      expect(SurveyItemResponse.where(survey_item: t_pcom_q3).count).to eq 4
    end

    it 'captures the likert scores for the survey item responses' do
      expect(SurveyItemResponse.where(response_id: 'survey_response_1').where(survey_item: t_pcom_q2)).to be_empty
      expect(SurveyItemResponse.where(response_id: 'survey_response_1').where(survey_item: t_pcom_q3).first.likert_score).to eq 3

      expect(SurveyItemResponse.where(response_id: 'survey_response_2').where(survey_item: t_pcom_q2)).to be_empty
      expect(SurveyItemResponse.where(response_id: 'survey_response_2').where(survey_item: t_pcom_q3)).to be_empty

      expect(SurveyItemResponse.where(response_id: 'survey_response_3').where(survey_item: t_pcom_q2).first.likert_score).to eq 5
      expect(SurveyItemResponse.where(response_id: 'survey_response_3').where(survey_item: t_pcom_q3).first.likert_score).to eq 5

      expect(SurveyItemResponse.where(response_id: 'survey_response_4').where(survey_item: t_pcom_q2).first.likert_score).to eq 4
      expect(SurveyItemResponse.where(response_id: 'survey_response_4').where(survey_item: t_pcom_q3).first.likert_score).to eq 4

      expect(SurveyItemResponse.where(response_id: 'survey_response_5').where(survey_item: t_pcom_q2).first.likert_score).to eq 2
      expect(SurveyItemResponse.where(response_id: 'survey_response_5').where(survey_item: t_pcom_q3).first.likert_score).to eq 4
    end

    it 'is idempotent, i.e. loading the data a second time does not duplicate survey item responses' do
      number_of_survey_item_responses = SurveyItemResponse.count

      SurveyResponsesDataLoader.load_data filepath: path_to_csv

      expect(SurveyItemResponse.count).to eq number_of_survey_item_responses
    end
  end
end
