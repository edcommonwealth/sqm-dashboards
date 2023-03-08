require 'rails_helper'

describe StaffingLoader do
  let(:path_to_staffing_data) { Rails.root.join('spec', 'fixtures', 'sample_staffing_data.csv') }
  let(:ay_2022_23) { create(:academic_year, range: '2022-23') }
  let(:ay_2021_22) { create(:academic_year, range: '2021-22') }
  let(:attleboro) { School.find_or_create_by(name: 'Attleboro', dese_id: 160_505) }
  let(:beachmont) { School.find_or_create_by(name: 'Beachmont', dese_id: 2_480_013) }
  let(:winchester) { School.find_or_create_by(name: 'Winchester', dese_id: 3_440_505) }

  before :each do
    ay_2022_23
    ay_2021_22
    attleboro
    beachmont
    winchester
    StaffingLoader.load_data filepath: path_to_staffing_data
    StaffingLoader.clone_previous_year_data
  end

  after :each do
    DatabaseCleaner.clean
  end

  context 'self.load_data' do
    it 'loads the correct staffing numbers' do
      academic_year = ay_2021_22
      expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 197.5

      expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 56.4

      expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 149.8
    end

    context 'when the staffing data is missing a school' do
      after :each do
        DatabaseCleaner.clean
      end
      it 'fills in empty staffing numbers with the previous years data' do
        academic_year = ay_2022_23
        expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 197.5

        expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 56.4

        expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 149.8
      end
    end
  end
end
