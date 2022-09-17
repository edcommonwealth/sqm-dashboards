require 'rails_helper'

RSpec.describe Dese::FiveCOne do
  let(:academic_years) do
    [
      create(:academic_year, range: '2020-21'),
      create(:academic_year, range: '2019-20')
      # create(:academic_year, range: '2018-19'),
      # create(:academic_year, range: '2017-18'),
      # create(:academic_year, range: '2016-17')
    ]
  end

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '5C_1_art_course.csv') }

  let(:filepaths) do
    [i1_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext '#run_all' do
    it 'creates a csv file with the scraped data' do
      Dese::FiveCOne.new(filepaths:).run_all
      expect(i1_filepath).to exist
    end

    it 'has the correct headers for i1' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'K', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
                             '11', '12', 'All Grades', "Total Students\n"]
    end

    it 'has the right likert score results for a-picp-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-picp-i1' && row['Academic Year'] == '2020-21'

        likert_score = row['Likert Score']
        likert_score == 'NA' ? likert_score : likert_score.to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.95, 2.39, 4.81, 4.89, 4.63, 4.95, 2.25, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 3.75,
                                      4.82, 1.0, 3.88, 3.14, 4.84, 5.0]
    end
  end
end
