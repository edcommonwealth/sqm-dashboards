require 'rails_helper'
RSpec.describe Dese::Loader do
  let(:path_to_admin_data) { Rails.root.join('spec', 'fixtures', 'sample_four_d_data.csv') }

  let(:ay_2022_23) { create(:academic_year, range: '2022-23') }
  let(:ay_2021_22) { create(:academic_year, range: '2021-22') }
  let(:ay_2020_21) { create(:academic_year, range: '2020-21') }
  let(:ay_2019_20) { create(:academic_year, range: '2019-20') }
  let(:ay_2018_19) { create(:academic_year, range: '2018-19') }
  let(:ay_2017_18) { create(:academic_year, range: '2017-18') }
  let(:ay_2016_17) { create(:academic_year, range: '2016-17') }
  let(:four_d) { create(:admin_data_item, admin_data_item_id: 'a-cgpr-i1') }
  let(:attleboro)  { create(:school, dese_id: 160_505) }
  let(:winchester) { create(:school, dese_id: 3_440_505) }
  let(:milford)    { create(:school, dese_id: 1_850_505) }
  let(:seacoast)   { create(:school, dese_id: 2_480_520) }
  let(:next_wave)  { create(:school, dese_id: 2_740_510) }

  before :each do
    ay_2022_23
    ay_2021_22
    ay_2020_21
    ay_2019_20
    ay_2018_19
    ay_2017_18
    ay_2016_17
    four_d
    attleboro
    winchester
    milford
    seacoast
    next_wave
  end

  after :each do
    # DatabaseCleaner.clean
  end
  context 'when running the loader' do
    before :each do
      Dese::Loader.load_data filepath: path_to_admin_data
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
      expect(AdminDataValue.count).to eq 25
    end

    it 'is idempotent' do
      Dese::Loader.load_data filepath: path_to_admin_data

      expect(AdminDataValue.count).to eq 25
    end
  end
end
