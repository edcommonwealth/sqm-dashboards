require 'rails_helper'

describe AdminDataLoader do
  let(:path_to_admin_data) { Rails.root.join('spec', 'fixtures', 'sample_admin_data.csv') }
  let(:ay_2018_19) { AcademicYear.find_by_range '2018-19' }
  let(:attleboro) { School.find_by_dese_id 160_505 }
  let(:winchester) { School.find_by_dese_id 3_440_505 }
  let(:chronic_absense_rate) { AdminDataItem.find_by_admin_data_item_id 'a-vale-i1' }
  let(:student_to_instructor_ratio) { AdminDataItem.find_by_admin_data_item_id 'a-sust-i3' }

  before :each do
    Rails.application.load_seed

    AdminDataLoader.load_data filepath: path_to_admin_data
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe 'self.load_data' do
    it 'loads the correct admin data values' do
      # it 'assigns the academic year to admin data value' do
      expect(AdminDataValue.where(school: attleboro,
                                  admin_data_item: chronic_absense_rate).first.academic_year).to eq ay_2018_19
      # end

      # it 'assigns the school to the admin data value' do
      expect(AdminDataValue.first.school).to eq attleboro
      expect(AdminDataValue.last.school).to eq winchester
      # end

      # it 'links the admin data value to the correct admin data item' do
      expect(AdminDataValue.first.admin_data_item).to eq chronic_absense_rate
      expect(AdminDataValue.last.admin_data_item).to eq student_to_instructor_ratio
      # end

      # it 'loads all the admin data values in the target csv file' do
      expect(AdminDataValue.count).to eq 11
      # end

      # it 'captures the likert score ' do
      expect(AdminDataValue.first.likert_score).to eq 3.03
      expect(AdminDataValue.last.likert_score).to eq 5
      # end

      # it 'rounds up any likert_scores between 0 and 1 (non-inclusive) to 1' do
      expect(AdminDataValue.where(school: attleboro, academic_year: ay_2018_19,
                                  admin_data_item: AdminDataItem.find_by_admin_data_item_id('a-sust-i3')).first.likert_score).to eq 1
      # end
      # it 'rejects importing rows with a value of 0' do
      expect(AdminDataValue.where(school: attleboro, academic_year: ay_2018_19,
                                  admin_data_item: AdminDataItem.find_by_admin_data_item_id('a-reso-i1'))).not_to exist
      # end
    end
  end
end
