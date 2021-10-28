require 'rails_helper'
require "#{Rails.root}/app/lib/seeder"

describe Seeder do
  let(:seeder) { Seeder.new }

  context 'academic years' do
    before { AcademicYear.delete_all }

    it 'seeds new academic years' do
      expect {
        seeder.seed_academic_years '2020-21', '2021-22', '2022-23'
      }.to change { AcademicYear.count }.by(3)
      expect(AcademicYear.all.map(&:range)).to eq ['2020-21', '2021-22', '2022-23']
    end

    context 'when partial data already exists' do
      before { create(:academic_year, range: '2020-21') }

      it 'only creates new data' do
        expect {
          seeder.seed_academic_years '2020-21', '2021-22'
        }.to change { AcademicYear.count }.by(1)
      end
    end
  end

  context 'districts and schools' do
    before(:each) do
      District.delete_all
      School.delete_all
    end

    it 'seeds new districts' do
      expect {
        seeder.seed_districts_and_schools sample_qualtrics_district_and_school_code_key_csv
      }.to change { District.count }.by(2)
    end

    it 'seeds new schools' do
      expect {
        seeder.seed_districts_and_schools sample_qualtrics_district_and_school_code_key_csv
      }.to change { School.count }.by(2)
    end

    context 'when partial data already exists' do
      let!(:existing_district) { create(:district, name: 'Boston') }
      let!(:existing_school) { create(:school, name: 'Samuel Adams Elementary School', slug: 'some-slug-for-sam-adams', district: existing_district) }

      it 'only creates new districts' do
        expect {
          seeder.seed_districts_and_schools sample_qualtrics_district_and_school_code_key_csv
        }.to change { District.count }.by(1)

        new_district = District.find_by_name 'Attleboro'
        expect(new_district.qualtrics_code).to eq 1
        expect(new_district.slug).to eq 'attleboro'
      end

      it 'updates existing districts with the correct data' do
        seeder.seed_districts_and_schools sample_qualtrics_district_and_school_code_key_csv

        existing_district.reload
        expect(existing_district.qualtrics_code).to eq 2
        expect(existing_district.slug).to eq 'boston'
      end

      it 'only creates new schools' do
        expect {
          seeder.seed_districts_and_schools sample_qualtrics_district_and_school_code_key_csv
        }.to change { School.count }.by(1)

        new_school = School.find_by_name 'Attleboro High School'
        expect(new_school.qualtrics_code).to eq 1
        expect(new_school.slug).to eq 'attleboro-high-school'
      end

      it 'updates existing schools with the qualtrics code' do
        seeder.seed_districts_and_schools sample_qualtrics_district_and_school_code_key_csv

        existing_school.reload
        expect(existing_school.qualtrics_code).to eq 1
        expect(existing_school.slug).to eq 'some-slug-for-sam-adams'
      end
    end
  end

  context 'the sqm framework' do
    before do
      category = create(:sqm_category, name: 'School Culture', sort_index: -1)
      subcategory = create(:subcategory, name: 'Safety', description: 'old description', sqm_category: category)
      measure = create(:measure, name: 'Student Physical Safety?', measure_id: '2A-i', subcategory: subcategory)
      create(:survey_item, survey_item_id: 's-phys-q1', measure: measure)
      create(:admin_data_item, admin_data_item_id: 'a-phys-i1', measure: measure)
    end

    it 'creates new objects as necessary' do
      expect {
        seeder.seed_sqm_framework sample_sqm_framework_csv
      }.to change { SqmCategory.count }.by(4)
       .and change { Subcategory.count }.by(15)
       .and change { Measure.count }.by(31)
       .and change { SurveyItem.count }.by(136)
       .and change { AdminDataItem.count }.by(32)
    end

    context 'updates records to match given data' do
      before :each do
        seeder.seed_sqm_framework sample_sqm_framework_csv
      end

      it 'updates category data' do
        seeder.seed_sqm_framework sample_sqm_framework_csv
        teachers_leadership = SqmCategory.find_by_name 'Teachers & Leadership'

        expect(teachers_leadership.slug).to eq 'teachers-and-leadership'
        expect(teachers_leadership.description).to eq "This is a category description."
      end

      it 'updates category sort index to match a predefined order' do
        teachers_leadership = SqmCategory.find_by_name 'Teachers & Leadership'
        school_culture = SqmCategory.find_by_name 'School Culture'

        expect(teachers_leadership.sort_index).to eq 0
        expect(school_culture.sort_index).to eq 1
      end

      it 'updates subcategory data' do
        subcategory = Subcategory.find_by_name 'Safety'
        expect(subcategory.description).to eq "This is a subcategory description."
      end

      it 'updates measure data' do
        measure = Measure.find_by_measure_id '2A-i'
        expect(measure.name).to eq 'Student Physical Safety'
        expect(measure.watch_low_benchmark).to eq 2.79
        expect(measure.growth_low_benchmark).to eq 3.3
        expect(measure.approval_low_benchmark).to eq 3.8
        expect(measure.ideal_low_benchmark).to eq 4.51
      end

      it 'does not overwrite the measure benchmarks with admin data benchmarks' do
        measure = Measure.find_by_measure_id '1A-i'
        expect(measure.approval_low_benchmark).to eq 3.5
      end

      it 'updates survey item data' do
        survey_item = SurveyItem.find_by_survey_item_id 's-phys-q1'
        expect(survey_item.prompt).to eq 'How often do you worry about violence at your school?'
      end

      it 'updates admin data item data' do
        admin_data_item = AdminDataItem.find_by_admin_data_item_id 'a-phys-i1'
        expect(admin_data_item.description).to eq 'Student to suspensions ratio'
      end
    end
  end

  private

  def sample_qualtrics_district_and_school_code_key_csv
    Rails.root.join('spec', 'fixtures', 'qualtrics_district_and_school_code_key.csv')
  end

  def sample_sqm_framework_csv
    Rails.root.join('spec', 'fixtures', 'sample_sqm_framework.csv')
  end

end
