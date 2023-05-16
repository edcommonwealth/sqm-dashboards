require 'rails_helper'

RSpec.describe SurveyItemValues, type: :model do
  let(:headers) do
    ['StartDate', 'EndDate', 'Status', 'IPAddress', 'Progress', 'Duration (in seconds)', 'Finished', 'RecordedDate',
     'ResponseId', 'RecipientLastName', 'RecipientFirstName', 'RecipientEmail', 'ExternalReference', 'LocationLatitude', 'LocationLongitude', 'DistributionChannel', 'UserLanguage', 'District', 'School- Lee', 'School- Maynard', 'LASID', 'Grade', 's-emsa-q1', 's-emsa-q2', 's-emsa-q3', 's-tint-q1', 's-tint-q2', 's-tint-q3', 's-tint-q4', 's-tint-q5', 's-acpr-q1', 's-acpr-q2', 's-acpr-q3', 's-acpr-q4', 's-cure-q1', 's-cure-q2', 's-cure-q3', 's-cure-q4', 's-sten-q1', 's-sten-q2', 's-sten-q3', 's-sper-q1', 's-sper-q2', 's-sper-q3', 's-sper-q4', 's-civp-q1', 's-civp-q2', 's-civp-q3', 's-civp-q4', 's-grmi-q1', 's-grmi-q2', 's-grmi-q3', 's-grmi-q4', 's-appa-q1', 's-appa-q2', 's-appa-q3', 's-peff-q1', 's-peff-q2', 's-peff-q3', 's-peff-q4', 's-peff-q5', 's-peff-q6', 's-sbel-q1', 's-sbel-q2', 's-sbel-q3', 's-sbel-q4', 's-sbel-q5', 's-phys-q1', 's-phys-q2', 's-phys-q3', 's-phys-q4', 's-vale-q1', 's-vale-q2', 's-vale-q3', 's-vale-q4', 's-acst-q1', 's-acst-q2', 's-acst-q3', 's-sust-q1', 's-sust-q2', 's-grit-q1', 's-grit-q2', 's-grit-q3', 's-grit-q4', 's-expa-q1', 's-poaf-q1', 's-poaf-q2', 's-poaf-q3', 's-poaf-q4', 's-tint-q1-1', 's-tint-q2-1', 's-tint-q3-1', 's-tint-q4-1', 's-tint-q5-1', 's-acpr-q1-1', 's-acpr-q2-1', 's-acpr-q3-1', 's-acpr-q4-1', 's-peff-q1-1', 's-peff-q2-1', 's-peff-q3-1', 's-peff-q4-1', 's-peff-q5-1', 's-peff-q6-1', 'Gender', 'Race']
  end
  let(:genders) do
    create(:gender, qualtrics_code: 1)
    gender_hash = {}

    Gender.all.each do |gender|
      gender_hash[gender.qualtrics_code] = gender
    end
    gender_hash
  end
  let(:survey_items) { [] }
  let(:attleboro) do
    create(:school, name: 'Attleboro', dese_id: 1234)
  end
  let(:attleboro_respondents) do
    create(:respondent, school: attleboro, academic_year: ay_2022_23, nine: 40, ten: 40, eleven: 40, twelve: 40)
  end
  let(:schools) { School.school_hash }
  let(:recorded_date) { '2023-04-01' }
  let(:ay_2022_23) do
    create(:academic_year, range: '2022-23')
  end

  context '.recorded_date' do
    it 'returns the recorded date' do
      row = { 'RecordedDate' => '2017-01-01' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.recorded_date).to eq Date.parse('2017-01-01')

      headers = ['Recorded Date']
      row = { 'Recorded Date' => '2017-01-02' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.recorded_date).to eq Date.parse('2017-01-02')
    end
  end

  context '.school' do
    it 'returns the school that maps to the dese id provided' do
      attleboro
      headers = ['Dese ID']
      row = { 'Dese ID' => '1234' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.school).to eq attleboro

      headers = ['School']
      row = { 'School' => '1234' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.school).to eq attleboro

      headers = ['School- Attleboro']
      row = { 'School- Attleboro' => '1234' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.school).to eq attleboro
    end
  end

  context '.grade' do
    it 'returns the grade that maps to the grade provided' do
      row = { 'Grade' => '1' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.grade).to eq 1
    end
  end

  context '.gender' do
    it 'returns the grade that maps to the grade provided' do
      row = { 'Gender' => '1' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.gender.qualtrics_code).to eq 1
    end
  end

  context '.dese_id' do
    it 'returns the dese id for the id provided' do
      headers = ['Dese ID']
      row = { 'Dese ID' => '11' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.dese_id).to eq 11
      headers = ['School']
      row = { 'School' => '22' }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.dese_id).to eq 22
    end
  end

  context '.survey_type' do
    it 'reads header to find the survey type' do
      headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
      values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
      expect(values.survey_type).to eq :student

      headers = %w[t-sbel-q5 t-phys-q2]
      values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
      expect(values.survey_type).to eq :teacher
    end
  end

  context '.valid_duration' do
    context 'when duration is valid' do
      it 'returns true' do
        headers = ['s-sbel-q5', 's-phys-q2', 'RecordedDate', 'Duration (in seconds)']
        values = SurveyItemValues.new(row: { 'Duration (in seconds)' => '240' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true

        headers = ['t-sbel-q5', 't-phys-q2', 'Duration (in seconds)']
        values = SurveyItemValues.new(row: { 'Duration (in seconds)' => '300' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true
      end
    end

    context 'when duration is invalid' do
      it 'returns false' do
        headers = ['s-sbel-q5', 's-phys-q2', 'RecordedDate', 'Duration (in seconds)']
        values = SurveyItemValues.new(row: { 'Duration (in seconds)' => '239' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq false

        headers = ['t-sbel-q5', 't-phys-q2', 'Duration (in seconds)']
        values = SurveyItemValues.new(row: { 'Duration (in seconds)' => '299' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq false
      end
    end
  end

  context '.valid_progress' do
    context 'when progress is valid' do
      it 'returns true' do
        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { 'Progress' => '25' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_progress?).to eq true
      end
    end

    context 'when progress is invalid' do
      it 'returns false' do
        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { 'Progress' => '24' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_progress?).to eq false
      end
    end
  end

  xcontext '.valid_grade?' do
    context 'when grade is valid' do
      before :each do
        attleboro
        attleboro_respondents
      end
      it 'returns true for students' do
        headers = %w[s-sbel-q5 s-phys-q2 grade RecordedDate]
        values = SurveyItemValues.new(row: { 'grade' => '9', 'RecordedDate' => recorded_date, 'Dese ID' => '1234' }, headers:, genders:, survey_items:,
                                      schools:)

        expect(values.valid_grade?).to eq true
      end
      xit 'returns true for teachers' do
        headers = %w[t-sbel-q5 t-phys-q2 grade RecordedDate]
        values = SurveyItemValues.new(row: { 'RecordedDate' => recorded_date, 'Dese ID' => '1234' }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_grade?).to eq true
      end
    end

    xcontext 'when grade is invalid' do
      before :each do
        attleboro
        attleboro_respondents
      end
      it 'returns false' do
        headers = %w[s-sbel-q5 s-phys-q2 grade RecordedDate]
        values = SurveyItemValues.new(row: { 'grade' => '2', 'RecordedDate' => recorded_date, 'Dese ID' => '1234' }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_grade?).to eq false
      end
    end
  end

  context '.valid_sd?' do
    context 'when the standard deviation is valid' do
      it 'returns true for student questions' do
        headers = %w[s-sbel-q5 s-phys-q1 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { 'RecordedDate' => recorded_date, 'Dese ID' => '1234', 's-sbel-q5' => '1', 's-phys-q1' => '', 's-phys-q2' => '5' }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq true
      end
      it 'returns true for teacher questions' do
        headers = %w[t-sbel-q5 t-phys-q2]
        values = SurveyItemValues.new(row: { 'RecordedDate' => recorded_date, 'Dese ID' => '1234', 't-sbel-q5' => '1', 't-phys-q2' => '5' }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq true
      end
    end

    context 'when the standard deviation is invalid' do
      it 'returns false for student questions' do
        headers = %w[s-sbel-q5 s-phys-q1 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { 'RecordedDate' => recorded_date, 'Dese ID' => '1234', 's-sbel-q5' => '1', 's-phys-q2' => '', 's-phys-q3' => '1' }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq false
      end
      it 'returns false for teacher questions' do
        headers = %w[t-sbel-q5 t-phys-q1 t-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { 'RecordedDate' => recorded_date, 'Dese ID' => '1234', 't-sbel-q5' => '1', 't-phys-q2' => '', 't-phys-q3' => '1' }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq false
      end
    end
  end
end
