require 'rails_helper'
require 'fileutils'

RSpec.describe Cleaner do
  let(:district) { create(:district, name: 'Maynard Public Schools') }
  let(:second_district) { create(:district, name: 'District2') }
  let(:school) { create(:school, dese_id: 1_740_505, district:) }
  let(:second_school) { create(:school, dese_id: 1_740_305, district:) }
  let(:third_school) { create(:school, dese_id: 222_222, district: second_district) }

  let(:academic_year) { create(:academic_year, range: '2022-23') }
  let(:respondents) do
    create(:respondent, school:, academic_year:, one: 0, nine: 40, ten: 40, eleven: 40, twelve: 40)
    create(:respondent, school: second_school, academic_year:, one: 0, four: 40, five: 40, six: 40, seven: 40,
                        eight: 40)
  end
  let(:recorded_date) { '2023-04-01' }
  let(:input_filepath) do
    Rails.root.join('spec', 'fixtures', 'raw')
  end

  let(:output_filepath) do
    Rails.root.join('tmp', 'spec', 'clean')
  end

  let(:log_filepath) do
    Rails.root.join('tmp', 'spec', 'removed')
  end

  let(:disaggregation_filepath) do
    Rails.root.join('spec', 'fixtures', 'disaggregation')
  end

  let(:path_to_sample_disaggregation_file) do
    File.open(Rails.root.join('spec', 'fixtures', 'disaggregation', 'sample_maynard_disaggregation_data.csv'))
  end

  let(:path_to_sample_raw_file) do
    File.open(Rails.root.join('spec', 'fixtures', 'raw', 'sample_maynard_raw_student_survey.csv'))
  end

  let(:common_headers) do
    ['Recorded Date', 'DeseID', 'ResponseID']
  end

  let(:standard_survey_items) do
    survey_item_ids = (%w[s-peff-q1 s-peff-q2 s-peff-q3 s-peff-q4 s-peff-q5 s-peff-q6 s-phys-q1 s-phys-q2 s-phys-q3 s-phys-q4
                          s-emsa-q1 s-emsa-q2 s-emsa-q3 s-sbel-q1 s-sbel-q2 s-sbel-q3 s-sbel-q4 s-sbel-q5 s-tint-q1 s-tint-q2
                          s-tint-q3 s-tint-q4 s-tint-q5 s-vale-q1 s-vale-q2 s-vale-q3 s-vale-q4 s-acpr-q1 s-acpr-q2 s-acpr-q3
                          s-acpr-q4 s-sust-q1 s-sust-q2 s-cure-q1 s-cure-q2 s-cure-q3 s-cure-q4 s-sten-q1 s-sten-q2 s-sten-q3
                          s-sper-q1 s-sper-q2 s-sper-q3 s-sper-q4 s-civp-q1 s-civp-q2 s-civp-q3 s-civp-q4 s-grit-q1 s-grit-q2
                          s-grit-q3 s-grit-q4 s-grmi-q1 s-grmi-q2 s-grmi-q3 s-grmi-q4 s-expa-q1 s-appa-q1 s-appa-q2 s-appa-q3
                          s-acst-q1 s-acst-q2 s-acst-q3 s-poaf-q1 s-poaf-q2 s-poaf-q3 s-poaf-q4] << common_headers).flatten
    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:)
    end
    survey_item_ids
  end

  let(:short_form_survey_items) do
    ([create(:survey_item, survey_item_id: 's-phys-q1', on_short_form: true),
      create(:survey_item, survey_item_id: 's-phys-q2', on_short_form: true),
      create(:survey_item, survey_item_id: 's-phys-q3',
                           on_short_form: true)].map(&:survey_item_id) << common_headers).flatten
  end

  let(:early_education_survey_items) do
    ([create(:survey_item, survey_item_id: 's-emsa-es1'),
      create(:survey_item, survey_item_id: 's-emsa-es2'),
      create(:survey_item, survey_item_id: 's-emsa-es3')].map(&:survey_item_id) << common_headers).flatten
  end

  let(:teacher_survey_items) do
    survey_item_ids = (%w[t-prep-q1 t-prep-q2 t-prep-q3 t-ieff-q1 t-ieff-q2 t-ieff-q3 t-ieff-q4 t-pcom-q1 t-pcom-q2 t-pcom-q3
                          t-pcom-q4 t-pcom-q5 t-inle-q1 t-inle-q2 t-inle-q3 t-prtr-q1 t-prtr-q2 t-prtr-q3 t-coll-q1 t-coll-q2
                          t-coll-q3 t-qupd-q1 t-qupd-q2 t-qupd-q3 t-qupd-q4 t-pvic-q1 t-pvic-q2 t-pvic-q3 t-psup-q1 t-psup-q2
                          t-psup-q3 t-psup-q4 t-acch-q1 t-acch-q2 t-acch-q3 t-reso-q1 t-reso-q2 t-reso-q3 t-reso-q4 t-reso-q5
                          t-sust-q1 t-sust-q2 t-sust-q3 t-sust-q4 t-curv-q1 t-curv-q2 t-curv-q3 t-curv-q4 t-cure-q1 t-cure-q2
                          t-cure-q3 t-cure-q4 t-peng-q1 t-peng-q2 t-peng-q3 t-peng-q4 t-ceng-q1 t-ceng-q2 t-ceng-q3 t-ceng-q4
                          t-sach-q1 t-sach-q2 t-sach-q3 t-psol-q1 t-psol-q2 t-psol-q3 t-expa-q2 t-expa-q3 t-phya-q2 t-phya-q3] << common_headers).flatten

    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:)
    end
    survey_item_ids
  end

  before :each do
    school
    second_school
    third_school
    standard_survey_items
    short_form_survey_items
    early_education_survey_items
    teacher_survey_items
    academic_year
    respondents
  end

  context 'Creating a new Cleaner' do
    it 'creates a directory for the clean data' do
      Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).clean
      expect(output_filepath).to exist
    end

    it 'creates a directory for the removed data' do
      Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).clean
      expect(log_filepath).to exist
    end
  end

  context '.process_raw_file' do
    it 'sorts data into valid and invalid csvs' do
      cleaner = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:)
      processed_data = cleaner.process_raw_file(
        file: path_to_sample_raw_file, disaggregation_data: cleaner.disaggregation_data
      )
      processed_data in [headers, clean_csv, log_csv, data]

      reads_headers_from_raw_csv(processed_data)

      valid_rows = %w[1000 1001 1004 1005 1008 1017 1018 1019 1020 1024 1025 1026
                      1027 1028]
      valid_rows.each do |response_id|
        valid_row = data.find { |row| row.response_id == response_id }
        expect(valid_row.valid?).to eq true
      end

      invalid_rows = %w[1002 1003 1006 1007 1009 1010 1011 1012 1013 1014 1015 1016 1021 1022 1023 1029 1030 1031 1032
                        1033 1034]
      invalid_rows.each do |response_id|
        invalid_row = data.find { |row| row.response_id == response_id }
        expect(invalid_row.valid?).to eq false
      end

      expect(clean_csv.length).to eq valid_rows.length + 1 # headers + rows
      expect(log_csv.length).to eq invalid_rows.length + 1 # headers + rows

      csv_contains_the_correct_rows(clean_csv, valid_rows)
      csv_contains_the_correct_rows(log_csv, invalid_rows)
      invalid_rows_are_rejected_for_the_correct_reasons(data)
    end

    it 'adds dissaggregation data to the cleaned file ' do
      cleaner = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:)
      processed_data = cleaner.process_raw_file(
        file: path_to_sample_raw_file, disaggregation_data: cleaner.disaggregation_data
      )
      processed_data in [headers, clean_csv, log_csv, data]
      expect(clean_csv.second.last).to eq 'Economically Disadvantaged - Y'

      one_thousand = data.find { |row| row.response_id == '1000' }
      expect(one_thousand.income).to eq 'Economically Disadvantaged - Y'

      one_thousand_one = data.find { |row| row.response_id == '1001' }
      expect(one_thousand_one.income).to eq 'Economically Disadvantaged - N'
    end
  end

  context '.filename' do
    context 'defines a filename in the format:  [district].[early_ed/short_form/standard/teacher].[year as 2022-23]' do
      context 'when the file is based on standard survey items' do
        it 'adds the survey type as standard to the filename' do
          survey_items = SurveyItem.where(survey_item_id: standard_survey_items)

          data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: standard_survey_items, genders: nil, survey_items:,
                                       schools: School.school_hash)]
          filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).filename(
            headers: standard_survey_items, data:
          )
          expect(filename).to eq 'maynard.standard.2022-23.csv'
        end

        context 'when the file is based on short form survey items' do
          it 'adds the survey type as short form to the filename' do
            survey_items = SurveyItem.where(survey_item_id: short_form_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: short_form_survey_items, genders: nil, survey_items:,
                                         schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).filename(
              headers: short_form_survey_items, data:
            )
            expect(filename).to eq 'maynard.short_form.2022-23.csv'
          end
        end

        context 'when the file is based on early education survey items' do
          it 'adds the survey type as early education to the filename' do
            survey_items = SurveyItem.where(survey_item_id: early_education_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: early_education_survey_items, genders: nil, survey_items:,
                                         schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).filename(
              headers: early_education_survey_items, data:
            )
            expect(filename).to eq 'maynard.early_education.2022-23.csv'
          end
        end
        context 'when the file is based on teacher survey items' do
          it 'adds the survey type as teacher to the filename' do
            survey_items = SurveyItem.where(survey_item_id: teacher_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: teacher_survey_items, genders: nil, survey_items:,
                                         schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).filename(
              headers: teacher_survey_items, data:
            )
            expect(filename).to eq 'maynard.teacher.2022-23.csv'
          end
        end

        context 'when there is more than one district' do
          it 'adds all districts to the filename' do
            survey_items = SurveyItem.where(survey_item_id: teacher_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: teacher_survey_items, genders: nil, survey_items:, schools: School.school_hash),
                    SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '222_222' },
                                         headers: teacher_survey_items, genders: nil, survey_items:, schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:).filename(
              headers: teacher_survey_items, data:
            )
            expect(filename).to eq 'maynard.district2.teacher.2022-23.csv'
          end
        end
      end
    end
  end
end

def reads_headers_from_raw_csv(processed_data)
  processed_data in [headers, clean_csv, log_csv, data]
  expect(headers).to eq ['StartDate', 'EndDate', 'Status', 'IPAddress', 'Progress', 'Duration (in seconds)',
                         'Finished', 'RecordedDate', 'ResponseId', 'District', 'School',
                         'LASID', 'Gender', 'Race', 'What grade are you in?', 's-emsa-q1', 's-emsa-q2', 's-emsa-q3', 's-tint-q1',
                         's-tint-q2', 's-tint-q3', 's-tint-q4', 's-tint-q5', 's-acpr-q1', 's-acpr-q2',
                         's-acpr-q3', 's-acpr-q4', 's-cure-q1', 's-cure-q2', 's-cure-q3', 's-cure-q4', 's-sten-q1', 's-sten-q2',
                         's-sten-q3', 's-sper-q1', 's-sper-q2', 's-sper-q3', 's-sper-q4', 's-civp-q1', 's-civp-q2', 's-civp-q3',
                         's-civp-q4', 's-grmi-q1', 's-grmi-q2', 's-grmi-q3', 's-grmi-q4', 's-appa-q1', 's-appa-q2', 's-appa-q3',
                         's-peff-q1', 's-peff-q2', 's-peff-q3', 's-peff-q4', 's-peff-q5', 's-peff-q6', 's-sbel-q1', 's-sbel-q2',
                         's-sbel-q3', 's-sbel-q4', 's-sbel-q5', 's-phys-q1', 's-phys-q2', 's-phys-q3', 's-phys-q4', 's-vale-q1',
                         's-vale-q2', 's-vale-q3', 's-vale-q4', 's-acst-q1', 's-acst-q2', 's-acst-q3', 's-sust-q1', 's-sust-q2',
                         's-grit-q1', 's-grit-q2', 's-grit-q3', 's-grit-q4', 's-expa-q1', 's-poaf-q1', 's-poaf-q2', 's-poaf-q3',
                         's-poaf-q4', 's-tint-q1-1', 's-tint-q2-1', 's-tint-q3-1', 's-tint-q4-1', 's-tint-q5-1', 's-acpr-q1-1',
                         's-acpr-q2-1', 's-acpr-q3-1', 's-acpr-q4-1', 's-peff-q1-1', 's-peff-q2-1', 's-peff-q3-1', 's-peff-q4-1',
                         's-peff-q5-1', 's-peff-q6-1', 'Raw Income', 'Income']
end

def invalid_rows_are_rejected_for_the_correct_reasons(data)
  one_thousand_two = data.find { |row| row.response_id == '1002' }
  expect(one_thousand_two.valid_progress?).to eq false
  expect(one_thousand_two.valid_duration?).to eq true
  expect(one_thousand_two.valid_grade?).to eq true
  expect(one_thousand_two.valid_sd?).to eq true

  one_thousand_three = data.find { |row| row.response_id == '1003' }
  expect(one_thousand_three.valid_progress?).to eq false
  expect(one_thousand_three.valid_duration?).to eq true
  expect(one_thousand_three.valid_grade?).to eq true
  expect(one_thousand_three.valid_sd?).to eq true

  one_thousand_six = data.find { |row| row.response_id == '1006' }
  expect(one_thousand_six.valid_progress?).to eq true
  expect(one_thousand_six.valid_duration?).to eq false
  expect(one_thousand_six.valid_grade?).to eq true
  expect(one_thousand_six.valid_sd?).to eq true

  one_thousand_seven = data.find { |row| row.response_id == '1007' }
  expect(one_thousand_seven.valid_progress?).to eq true
  expect(one_thousand_seven.valid_duration?).to eq false
  expect(one_thousand_seven.valid_grade?).to eq true
  expect(one_thousand_seven.valid_sd?).to eq true

  one_thousand_seven = data.find { |row| row.response_id == '1007' }
  expect(one_thousand_seven.valid_progress?).to eq true
  expect(one_thousand_seven.valid_duration?).to eq false
  expect(one_thousand_seven.valid_grade?).to eq true
  expect(one_thousand_seven.valid_sd?).to eq true

  one_thousand_nine = data.find { |row| row.response_id == '1009' }
  expect(one_thousand_nine.valid_progress?).to eq true
  expect(one_thousand_nine.valid_duration?).to eq true
  expect(one_thousand_nine.valid_grade?).to eq false
  expect(one_thousand_nine.valid_sd?).to eq true

  one_thousand_ten = data.find { |row| row.response_id == '1010' }
  expect(one_thousand_ten.valid_progress?).to eq true
  expect(one_thousand_ten.valid_duration?).to eq true
  expect(one_thousand_ten.valid_grade?).to eq false
  expect(one_thousand_ten.valid_sd?).to eq true

  one_thousand_eleven = data.find { |row| row.response_id == '1011' }
  expect(one_thousand_eleven.valid_progress?).to eq true
  expect(one_thousand_eleven.valid_duration?).to eq true
  expect(one_thousand_eleven.valid_grade?).to eq false
  expect(one_thousand_eleven.valid_sd?).to eq true

  one_thousand_twenty_two = data.find { |row| row.response_id == '1022' }
  expect(one_thousand_twenty_two.valid_progress?).to eq true
  expect(one_thousand_twenty_two.valid_duration?).to eq true
  expect(one_thousand_twenty_two.valid_grade?).to eq false
  expect(one_thousand_twenty_two.valid_sd?).to eq true

  one_thousand_twenty_three = data.find { |row| row.response_id == '1023' }
  expect(one_thousand_twenty_three.valid_progress?).to eq true
  expect(one_thousand_twenty_three.valid_duration?).to eq true
  expect(one_thousand_twenty_three.valid_grade?).to eq false
  expect(one_thousand_twenty_three.valid_sd?).to eq true

  one_thousand_thirty_three = data.find { |row| row.response_id == '1033' }
  expect(one_thousand_thirty_three.valid_progress?).to eq true
  expect(one_thousand_thirty_three.valid_duration?).to eq true
  expect(one_thousand_thirty_three.valid_grade?).to eq true
  expect(one_thousand_thirty_three.valid_sd?).to eq false

  one_thousand_thirty_four = data.find { |row| row.response_id == '1034' }
  expect(one_thousand_thirty_four.valid_progress?).to eq true
  expect(one_thousand_thirty_four.valid_duration?).to eq true
  expect(one_thousand_thirty_four.valid_grade?).to eq true
  expect(one_thousand_thirty_four.valid_sd?).to eq false
end

def csv_contains_the_correct_rows(csv, rows)
  rows.each_with_index do |row, index|
    response_id = 8 # eigth column
    expect(csv[index + 1][response_id]).to eq row
  end
end
