require 'rails_helper'
require 'fileutils'
require 'csv'

RSpec.describe Dese::ThreeBOne do
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

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'three_b_one_masscore.csv') }
  let(:i2_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'three_b_one_advcoursecomprate.csv') }
  let(:i3_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'three_b_one_ap.csv') }

  let(:filepaths) do
    [i1_filepath, i2_filepath, i3_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  context 'Creating a new Scraper' do
    it 'creates a csv file with the scraped data' do
      Dese::ThreeBOne.new(filepaths:).run_all
      expect(i1_filepath).to exist
      expect(i2_filepath).to exist
      expect(i3_filepath).to exist
    end

    it 'has the correct headers for a-curv-i1' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '# Graduated', '# Completed MassCore', "% Completed MassCore\n"]
    end
    it 'has the correct headers for a-curv-i2' do
      headers = File.open(i2_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '# Grade 11 and 12 Students', '# Students Completing Advanced', '% Students Completing Advanced',
                             '% ELA', '% Math', '% Science and Technology', '% Computer and Information Science',
                             '% History and Social Sciences', '% Arts', '% All Other Subjects', "% All Other Subjects\n"]
    end

    it 'has the correct headers for a-curv-i3' do
      headers = File.open(i3_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'Tests Taken', 'Score=1', 'Score=2', 'Score=3', 'Score=4', 'Score=5', '% Score 1-2', "% Score 3-5\n"]
    end

    it 'has the right likert score results for a-curv-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-curv-i1' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.44, 4.44, 3.33, 3.83, 4.44, 3.6, 4.44, 4.44, 1, 4.44, 4.44, 4.44, 4.44, 3.89,
                                      4.44, 4.44, 4.44, 4.44, 4.01, 3.92]
    end

    it 'has the right likert score results for a-curv-i2' do
      results = CSV.parse(File.read(i2_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-curv-i2' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 1.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
                                      5.0, 2.53, 5.0, 5.0]
    end
    it 'has the right likert score results for a-curv-i3' do
      results = CSV.parse(File.read(i3_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-curv-i3' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 1.46, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 2.06, 3.54, 5.0,
                                      5.0, 5.0, 5.0, 5.0, 1.0]
    end
  end
end
