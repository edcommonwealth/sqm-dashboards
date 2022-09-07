require 'rails_helper'
require 'fileutils'
require 'csv'

RSpec.describe Dese::TwoCOneScraper do
  let(:academic_years) do
    [
      create(:academic_year, range: '2021-22'),
      create(:academic_year, range: '2020-21'),
      create(:academic_year, range: '2019-20'),
      create(:academic_year, range: '2018-19'),
      create(:academic_year, range: '2017-18'),
      create(:academic_year, range: '2016-17')
    ]
  end

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'two_c_one_attendance.csv') }

  let(:filepaths) do
    [i1_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  context 'Creating a new Scraper' do
    it 'creates a csv file with the scraped data' do
      Dese::TwoCOneScraper.new(filepaths:)
      expect(i1_filepath).to exist
    end

    it 'has the correct headers' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'Attendance Rate', 'Average # of Absences', 'Absent 10 or more days', 'Chronically Absent (10% or more)',
                             'Chronically Absent (20% or more)', "Unexcused > 9 days\n"]
    end

    it 'has the right likert score results for a-vale-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-vale-i1' && row['Academic Year'] == '2021-22'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [1.88, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 3.16, 3.84, 1.0, 4.6, 3.64, 4.84, 2.68, 2.84,
                                      3.08, 1.0, 2.56, 3.96, 1.0]
    end
    it 'has the right likert score results for a-vale-i2' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-vale-i2' && row['Academic Year'] == '2021-22'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.2, 4.07, 4.11, 4.14, 4.0, 3.93, 3.92, 4.22, 4.21, 4.09, 4.24, 4.2, 4.26, 4.19,
                                      4.2, 4.22, 4.16, 4.18, 4.23, 4.02]
    end
  end
end
