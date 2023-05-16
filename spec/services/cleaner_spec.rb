require 'rails_helper'
require 'fileutils'

RSpec.describe Cleaner do
  let(:district) { create(:district, name: 'District1') }
  let(:second_district) { create(:district, name: 'District2') }
  let(:school) { create(:school, dese_id: 1_740_505, district:) }
  let(:second_school) { create(:school, dese_id: 222_222, district: second_district) }

  let(:academic_year) { create(:academic_year, range: '2022-23') }
  let(:respondents) { create(:respondent, school:, academic_year:, nine: 40, ten: 40, eleven: 40, twelve: 40) }
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

  let(:common_headers) do
    ['Recorded Date', 'Dese ID', 'ResponseID']
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
    standard_survey_items
    short_form_survey_items
    early_education_survey_items
    teacher_survey_items
    academic_year
    respondents
  end

  context 'Creating a new Cleaner' do
    it 'creates a directory for the clean data' do
      Cleaner.new(input_filepath:, output_filepath:, log_filepath:).clean
      expect(output_filepath).to exist
    end

    it 'creates a directory for the removed data' do
      Cleaner.new(input_filepath:, output_filepath:, log_filepath:).clean
      expect(log_filepath).to exist
    end
  end

  context '.filename' do
    context 'defines a filename in the format:  [district].[early_ed/short_form/standard/teacher].[year as 2022-23]' do
      context 'when the file is based on standard survey items' do
        it 'adds the survey type as standard to the filename' do
          survey_items = SurveyItem.where(survey_item_id: standard_survey_items)

          data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: standard_survey_items, genders: nil, survey_items:,
                                       schools: School.school_hash)]
          filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:).filename(
            headers: standard_survey_items, data:
          )
          expect(filename).to eq 'district1.standard.2022-23.csv'
        end

        context 'when the file is based on short form survey items' do
          it 'adds the survey type as short form to the filename' do
            survey_items = SurveyItem.where(survey_item_id: short_form_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: short_form_survey_items, genders: nil, survey_items:,
                                         schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:).filename(
              headers: short_form_survey_items, data:
            )
            expect(filename).to eq 'district1.short_form.2022-23.csv'
          end
        end

        context 'when the file is based on early education survey items' do
          it 'adds the survey type as early education to the filename' do
            survey_items = SurveyItem.where(survey_item_id: early_education_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: early_education_survey_items, genders: nil, survey_items:,
                                         schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:).filename(
              headers: early_education_survey_items, data:
            )
            expect(filename).to eq 'district1.early_education.2022-23.csv'
          end
        end
        context 'when the file is based on teacher survey items' do
          it 'adds the survey type as teacher to the filename' do
            survey_items = SurveyItem.where(survey_item_id: teacher_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: teacher_survey_items, genders: nil, survey_items:,
                                         schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:).filename(
              headers: teacher_survey_items, data:
            )
            expect(filename).to eq 'district1.teacher.2022-23.csv'
          end
        end

        context 'when there is more than one district' do
          it 'adds all districts to the filename' do
            survey_items = SurveyItem.where(survey_item_id: teacher_survey_items)

            data = [SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '1_740_505' }, headers: teacher_survey_items, genders: nil, survey_items:, schools: School.school_hash),
                    SurveyItemValues.new(row: { 'Recorded Date' => recorded_date, 'Dese ID' => '222_222' },
                                         headers: teacher_survey_items, genders: nil, survey_items:, schools: School.school_hash)]
            filename = Cleaner.new(input_filepath:, output_filepath:, log_filepath:).filename(
              headers: teacher_survey_items, data:
            )
            expect(filename).to eq 'district1.district2.teacher.2022-23.csv'
          end
        end
      end
    end
  end
end
