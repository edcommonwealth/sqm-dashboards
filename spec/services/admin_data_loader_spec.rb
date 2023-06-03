require 'rails_helper'

describe AdminDataLoader do
  let(:path_to_admin_data) { Rails.root.join('spec', 'fixtures', 'sample_admin_data.csv') }
  let(:path_to_secondary_admin_data) { Rails.root.join('spec', 'fixtures', 'secondary_sample_admin_data.csv') }
  let(:ay_2018_19) { create(:academic_year, range: '2018-19') }
  let(:attleboro) { create(:school, name: 'Attleboro High School', dese_id: 160_505) }
  let(:winchester) { create(:school, name: 'Winchester High School', dese_id: 3_440_505) }
  let(:beachmont) { create(:school, dese_id: 2_480_013) }
  let(:woodland) { create(:school, dese_id: 1_850_090) } # not explicitly tested
  let(:chronic_absense_rate) { create(:admin_data_item, admin_data_item_id: 'a-vale-i1') }
  let(:student_to_instructor_ratio) { create(:admin_data_item, admin_data_item_id: 'a-sust-i3') }
  let(:a_reso) { create(:admin_data_item, admin_data_item_id: 'a-reso-i1') } # not explicitly tested

  before :each do
    ay_2018_19
    attleboro
    winchester
    beachmont
    woodland
    chronic_absense_rate
    student_to_instructor_ratio
    a_reso
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
      expect(AdminDataValue.find_by(school: attleboro, academic_year: ay_2018_19,
                                    admin_data_item: chronic_absense_rate).likert_score).to eq 3.03
      expect(AdminDataValue.find_by(school: beachmont, academic_year: ay_2018_19,
                                    admin_data_item: student_to_instructor_ratio).likert_score).to eq 3.5
      expect(AdminDataValue.find_by(school: winchester, academic_year: ay_2018_19,
                                    admin_data_item: student_to_instructor_ratio).likert_score).to eq 5
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

    context 'when a second file exists' do
      before :each do
        AdminDataLoader.load_data filepath: path_to_secondary_admin_data
      end

      it 'updates likert scores to match the new file' do
        expect(AdminDataValue.find_by(school: attleboro, academic_year: ay_2018_19,
                                      admin_data_item: chronic_absense_rate).likert_score).to eq 1
        expect(AdminDataValue.find_by(school: beachmont, academic_year: ay_2018_19,
                                      admin_data_item: student_to_instructor_ratio).likert_score).to eq 3
      end
    end
  end

  describe 'output to console' do
    it 'outputs a messsage saying a value has been rejected' do
      output = capture_stdout { AdminDataLoader.load_data filepath: path_to_admin_data }.delete("\n")
      expect(output).to eq 'Invalid score: 0.0        for school: Attleboro High School        admin data item a-reso-i1 '
    end
  end
end

def capture_stdout
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end
