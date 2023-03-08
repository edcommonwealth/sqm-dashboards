require 'rails_helper'

describe EnrollmentLoader do
  let(:path_to_enrollment_data) { Rails.root.join('spec', 'fixtures', 'sample_enrollment_data.csv') }
  let(:ay_2022_23) { create(:academic_year, range: '2022-23') }

  let(:attleboro) { School.find_or_create_by(name: 'Attleboro', dese_id: 160_505) }
  let(:beachmont) { School.find_or_create_by(name: 'Beachmont', dese_id: 2_480_013) }
  let(:winchester) { School.find_or_create_by(name: 'Winchester', dese_id: 3_440_505) }
  before :each do
    ay_2022_23
    attleboro
    beachmont
    winchester
    EnrollmentLoader.load_data filepath: path_to_enrollment_data
  end

  after :each do
    DatabaseCleaner.clean
  end

  context 'self.load_data' do
    it 'loads the correct enrollment numbers' do
      academic_year = ay_2022_23
      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 506
      # expect(Respondent.find_by(school: attleboro, academic_year:).total_students).to eq 1844

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 34
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 64
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 58
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 336

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 361
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 331
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 339
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 352
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 1383
    end
  end
end
