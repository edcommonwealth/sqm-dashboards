require 'rails_helper'
require 'fileutils'
require 'csv'

RSpec.describe Dese::FourAOne do
  let(:academic_years) do
    [
      create(:academic_year, range: '2021-22'),
      create(:academic_year, range: '2020-21')
      # create(:academic_year, range: '2019-20'),
      # create(:academic_year, range: '2018-19'),
      # create(:academic_year, range: '2017-18'),
      # create(:academic_year, range: '2016-17')
    ]
  end

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '4A_1_grade_nine_course_pass.csv') }

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
      Dese::FourAOne.new(filepaths:).run_all
      expect(i1_filepath).to exist
    end

    it 'has the correct headers' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '# Grade Nine Students', '# Passing All Courses', "% Passing All Courses\n"]
    end
    it 'has the right likert score results for a-ovpe-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-ovpe-i1' && row['Academic Year'] == '2020-21'

        likert_score = row['Likert Score']
        likert_score == 'NA' ? likert_score : likert_score.to_f
      end.flatten.compact

      expect(results.take(20)).to eq [3.73, 3.37, 3.03, 4.03, 3.78, 3.17, 2.93, 'NA', 3.5, 4.0, 2.98, 3.84, 3.76, 3.93,
                                      4.05, 3.13, 3.92, 3.62, 3.49, 2.5]
    end
  end
end
