require 'rails_helper'

RSpec.describe Dese::FiveDTwo do
  let(:academic_years) do
    [
      create(:academic_year, range: '2021-22'),
      create(:academic_year, range: '2020-21')
      # create(:academic_year, range: '2019-20')
      # create(:academic_year, range: '2018-19'),
      # create(:academic_year, range: '2017-18'),
      # create(:academic_year, range: '2016-17')
    ]
  end

  let(:enrollments_filepath) { Rails.root.join('tmp', 'spec', 'dese', '5D_2_enrollments.csv') }
  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '5D_2_age_staffing.csv') }

  let(:filepaths) do
    [enrollments_filepath, i1_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext '#run_all' do
    it 'creates a csv file with the scraped data' do
      Dese::FiveDTwo.new(filepaths:).run_all
      expect(enrollments_filepath).to exist
      expect(i1_filepath).to exist
    end

    it 'has the correct headers for enrollements' do
      headers = File.open(enrollments_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'PK', 'K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'SP', "Total\n"]
    end

    it 'has the correct headers for i1' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '<26 yrs (# )', '26-32 yrs (#)', '33-40 yrs (#)', '41-48 yrs (#)', '49-56 yrs (#)', '57-64 yrs (#)', 'Over 64 yrs (#)', "FTE Count\n"]
    end

    it 'has the right likert score results for a-phya-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-phya-i1' && row['Academic Year'] == '2020-21'

        likert_score = row['Likert Score']
        likert_score == 'NA' ? likert_score : likert_score.to_f
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 1.0, 4.7, 4.59, 5.0, 5.0, 1.0, 3.33, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
                                      5.0, 5.0, 4.78, 5.0]
    end
  end
end
