require 'rails_helper'
RSpec.describe Dese::FourDLoader, type: :model do
  let(:path_to_admin_data) { Rails.root.join('spec', 'fixtures', 'sample_four_d_data.csv') }
  let(:ay_2020_21) { AcademicYear.find_by_range '2020-21' }
  let(:ay_2018_19) { AcademicYear.find_by_range '2018-19' }
  let(:ay_2017_18) { AcademicYear.find_by_range '2017-18' }
  let(:ay_2016_17) { AcademicYear.find_by_range '2016-17' }
  let(:four_d) { AdminDataItem.find_by_admin_data_item_id 'a-cgpr-i1' }
  let(:attleboro) { School.find_by_dese_id 160_505 }
  let(:winchester) { School.find_by_dese_id 3_440_505 }
  let(:milford) { School.find_by_dese_id 1_850_505 }
  let(:seacoast) { School.find_by_dese_id 2_480_520 }
  let(:next_wave) { School.find_by_dese_id 2_740_510 }

  before :each do
    Rails.application.load_seed
  end

  after :each do
    DatabaseCleaner.clean
  end
  context 'when running the loader' do
    before :each do
      Dese::FourDLoader.load_data filepath: path_to_admin_data
    end

    it 'load the correct admin data values' do
      expect(AdminDataValue.find_by(school: winchester, admin_data_item: four_d,
                                    academic_year: ay_2016_17).likert_score).to eq 5
      expect(AdminDataValue.find_by(school: attleboro, admin_data_item: four_d,
                                    academic_year: ay_2018_19).likert_score).to eq 5
      expect(AdminDataValue.find_by(school: milford, admin_data_item: four_d,
                                    academic_year: ay_2017_18).likert_score).to eq 4.92
      expect(AdminDataValue.find_by(school: seacoast, admin_data_item: four_d,
                                    academic_year: ay_2020_21).likert_score).to eq 3.84
      expect(AdminDataValue.find_by(school: next_wave, admin_data_item: four_d,
                                    academic_year: ay_2020_21).likert_score).to eq 4.8
    end

    it 'loads the correct number of items' do
      expect(AdminDataValue.count).to eq 230
    end

    it 'is idempotent' do
      Dese::FourDLoader.load_data filepath: path_to_admin_data

      expect(AdminDataValue.count).to eq 230
    end
  end
end
