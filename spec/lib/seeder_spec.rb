require 'rails_helper'
require "#{Rails.root}/app/lib/seeder"

describe Seeder do
  let(:seeder) { Seeder.new }

  context 'academic years' do
    before { AcademicYear.delete_all }

    it 'seeds new academic years' do
      expect do
        seeder.seed_academic_years '2020-21', '2021-22', '2022-23'
      end.to change { AcademicYear.count }.by(3)
      expect(AcademicYear.all.map(&:range)).to eq %w[2020-21 2021-22 2022-23]
    end

    context 'when partial data already exists' do
      before { create(:academic_year, range: '2020-21') }

      it 'only creates new data' do
        expect do
          seeder.seed_academic_years '2020-21', '2021-22'
        end.to change { AcademicYear.count }.by(1)
      end
    end
  end

  context 'districts and schools' do
    before(:each) do
      District.delete_all
      School.delete_all
    end

    it 'seeds new districts and schools' do
      expect do
        seeder.seed_districts_and_schools sample_districts_and_schools_csv
      end.to change { District.count }.by(2)
                                      .and change { School.count }.by(3)

      high_school = School.find_by_dese_id 160_505
      expect(high_school.name).to eq 'Attleboro High School'
      expect(high_school.is_hs).to be true

      elementary_school = School.find_by_dese_id 350_302
      expect(elementary_school.name).to eq 'Samuel Adams Elementary School'
      expect(elementary_school.is_hs).to be false
    end

    context 'when partial data already exists' do
      let!(:existing_district) { create(:district, name: 'Boston') }
      let!(:removed_school) do
        create(:school, name: 'John Oldest Academy', dese_id: 12_345, district: existing_district)
      end
      let!(:removed_survey_item_response) { create(:survey_item_response, school: removed_school) }
      let!(:existing_school) do
        create(:school, name: 'Sam Adams Elementary School', dese_id: 350_302, slug: 'some-slug-for-sam-adams',
                        district: existing_district)
      end

      it 'only creates new districts and schools' do
        expect do
          seeder.seed_districts_and_schools sample_districts_and_schools_csv
        end.to change { District.count }.by(1)
                                        .and change {
                                               School.count
                                             }.by(1) # +2 for schools added from example csv, -1 for old school

        new_district = District.find_by_name 'Attleboro'
        expect(new_district.qualtrics_code).to eq 1
        expect(new_district.slug).to eq 'attleboro'

        new_school = School.find_by_name 'Attleboro High School'
        expect(new_school.dese_id).to eq 160_505
        expect(new_school.qualtrics_code).to eq 1
        expect(new_school.slug).to eq 'attleboro-high-school'
      end

      it 'updates existing districts and schools with the correct data' do
        seeder.seed_districts_and_schools sample_districts_and_schools_csv

        existing_district.reload
        expect(existing_district.qualtrics_code).to eq 2
        expect(existing_district.slug).to eq 'boston'

        existing_school.reload
        expect(existing_school.qualtrics_code).to eq 1
        expect(existing_school.name).to eq 'Samuel Adams Elementary School'
        expect(existing_school.slug).to eq 'some-slug-for-sam-adams'
      end

      it 'removes any schools and associated child objects not contained within the CSV' do
        seeder.seed_districts_and_schools sample_districts_and_schools_csv

        expect(School.where(id: removed_school)).not_to exist
        expect(SurveyItemResponse.where(id: removed_survey_item_response)).not_to exist
      end
    end
  end

  context 'respondents' do
    before :each do
      create(:academic_year, range: '2020-21')
      seeder.seed_districts_and_schools sample_districts_and_schools_csv
    end

    it 'seeds the total number of respondents for a school' do
      expect do
        seeder.seed_respondents sample_districts_and_schools_csv
      end.to change { Respondent.count }.by(School.count)
    end

    it 'seeds idempotently' do
      expect do
        seeder.seed_respondents sample_districts_and_schools_csv
      end.to change { Respondent.count }.by(School.count)

      expect(Respondent.all.count).to eq School.count

      expect do
        seeder.seed_respondents sample_districts_and_schools_csv
      end.to change { Respondent.count }.by(0)
    end

    it 'seeds new respondents for every year in the database' do
      expect do
        seeder.seed_respondents sample_districts_and_schools_csv
      end.to change { Respondent.count }.by School.count

      expect do
        create(:academic_year, range: '2019-20')
        seeder.seed_respondents sample_districts_and_schools_csv
      end.to change { Respondent.count }.by School.count
    end
    it 'seeds the total number of students and teachers even if the original number includes commas' do
      seeder.seed_respondents sample_districts_and_schools_csv
      school = School.find_by_name('Attleboro High School')
      academic_year = AcademicYear.find_by_range('2020-21')
      school_with_over_one_thousand_student_respondents = Respondent.where(school:, academic_year:).first
      expect(school_with_over_one_thousand_student_respondents.total_students).to eq 1792
    end
  end

  context 'surveys' do
    before :each do
      create(:academic_year, range: '2020-21')
      seeder.seed_districts_and_schools sample_districts_and_schools_csv
      seeder.seed_surveys sample_districts_and_schools_csv
    end
    it 'for one academic year, it seeds a count of surveys equal to the count of schools' do
      expect(Survey.count).to eq School.count
    end

    it 'marks short form schools as short form schools' do
      elementary_school = School.find_by_dese_id 160_001
      academic_year = AcademicYear.find_by_range '2020-21'
      survey = Survey.where(school: elementary_school, academic_year:).first
      expect(survey.form).to eq 'short'
    end

    it 'does not mark long form schools as short form schools' do
      elementary_school = School.find_by_dese_id 350_302
      academic_year = AcademicYear.find_by_range '2020-21'
      survey = Survey.where(school: elementary_school, academic_year:).first
      expect(survey.form).to eq 'normal'
    end
    it 'seed idempotently' do
      expect do
        seeder.seed_surveys sample_districts_and_schools_csv
      end.to change { Survey.count }.by 0
    end
    it 'seeds new surveys for every year in the database' do
      expect do
        create(:academic_year, range: '2019-20')
        seeder.seed_surveys sample_districts_and_schools_csv
      end.to change { Survey.count }.by School.count
    end
  end

  context 'the sqm framework' do
    before do
      school_culture_category = create(:category, category_id: '2', sort_index: -1)
      safety_subcategory = create(:subcategory, subcategory_id: '2A', category: school_culture_category)
      physical_safety_measure = create(:measure, measure_id: '2A-i', subcategory: safety_subcategory)
      student_physical_safety_scale = create(:scale, scale_id: 's-phys', measure: physical_safety_measure)
      create(:survey_item, survey_item_id: 's-phys-q1', scale: student_physical_safety_scale)
      admin_physical_safety_scale = create(:scale, scale_id: 'a-phys', measure: physical_safety_measure)
      create(:admin_data_item, admin_data_item_id: 'a-phys-i1', scale: admin_physical_safety_scale)
    end

    it 'creates new objects as necessary' do
      expect do
        seeder.seed_sqm_framework sample_sqm_framework_csv
      end.to change { Category.count }.by(4)
                                      .and change { Subcategory.count }.by(15)
                                                                       .and change { Measure.count }.by(31).and change {
                                                                                                                  Scale.count
                                                                                                                }.by(51)
        .and change {
               SurveyItem.count
             }.by(136)
        .and change {
               AdminDataItem.count
             }.by(32)
    end

    context 'updates records to match given data' do
      before :each do
        seeder.seed_sqm_framework sample_sqm_framework_csv
      end

      it 'updates category data' do
        teachers_leadership = Category.find_by_name 'Teachers & Leadership'

        expect(teachers_leadership.slug).to eq 'teachers-and-leadership'
        expect(teachers_leadership.description).to eq 'This is a category description.'
        expect(teachers_leadership.short_description).to eq 'This is a category short description.'
      end

      it 'updates category sort index to match a predefined order' do
        teachers_leadership = Category.find_by_name 'Teachers & Leadership'
        school_culture = Category.find_by_name 'School Culture'

        expect(teachers_leadership.sort_index).to eq 0
        expect(school_culture.sort_index).to eq 1
      end

      it 'updates subcategory data' do
        subcategory = Subcategory.find_by_name 'Safety'
        expect(subcategory.description).to eq 'This is a subcategory description.'
      end

      it 'updates measure data' do
        measure = Measure.find_by_measure_id '2A-i'
        expect(measure.name).to eq 'Student Physical Safety'
        expect(measure.description).to eq 'This is a measure description.'
      end

      it 'updates scale references' do
        scale = Scale.find_by_scale_id 't-pcom'
        measure = Measure.find_by_measure_id '1A-iii'
        survey_item = SurveyItem.find_by_survey_item_id 't-pcom-q1'
        expect(scale.measure).to eq measure
        expect(scale.survey_items).to include survey_item
      end

      it 'does not overwrite the survey item benchmarks with admin data benchmarks' do
        survey_item = SurveyItem.find_by_survey_item_id 't-prep-q1'
        expect(survey_item.approval_low_benchmark).to eq 3.5
      end

      it 'updates survey item data' do
        survey_item = SurveyItem.find_by_survey_item_id 's-phys-q1'
        expect(survey_item.prompt).to eq 'How often do you worry about violence at your school?'
        expect(survey_item.watch_low_benchmark).to eq 2.79
        expect(survey_item.growth_low_benchmark).to eq 3.3
        expect(survey_item.approval_low_benchmark).to eq 3.8
        expect(survey_item.ideal_low_benchmark).to eq 4.51
        expect(survey_item.on_short_form).to eq false

        short_form_item = SurveyItem.find_by_survey_item_id 's-peff-q6'
        expect(short_form_item.on_short_form).to eq true
      end

      it 'updates admin data item data' do
        admin_data_item = AdminDataItem.find_by_admin_data_item_id 'a-phys-i1'
        expect(admin_data_item.watch_low_benchmark).to eq 2.99
        expect(admin_data_item.growth_low_benchmark).to eq 3.5
        expect(admin_data_item.approval_low_benchmark).to eq 4
        expect(admin_data_item.ideal_low_benchmark).to eq 4.71
        expect(admin_data_item.description).to eq 'Student to suspensions ratio'
        expect(admin_data_item.hs_only_item).to be false

        hs_admin_data_item = AdminDataItem.find_by_admin_data_item_id 'a-curv-i1'
        expect(hs_admin_data_item.hs_only_item).to be true
      end
    end
  end

  private

  def sample_districts_and_schools_csv
    Rails.root.join('spec', 'fixtures', 'sample_districts_and_schools.csv')
  end

  def sample_sqm_framework_csv
    Rails.root.join('spec', 'fixtures', 'sample_sqm_framework.csv')
  end
end
