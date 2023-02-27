require 'rails_helper'
require 'fileutils'

RSpec.describe Dese::FourBTwo do
  let(:academic_years) do
    [
      create(:academic_year, range: '2021-22'),
      create(:academic_year, range: '2020-21'),
      create(:academic_year, range: '2019-20')
      # create(:academic_year, range: '2018-19'),
      # create(:academic_year, range: '2017-18'),
      # create(:academic_year, range: '2016-17')
    ]
  end

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '4B_2_four_year_grad.csv') }
  let(:i2_filepath) { Rails.root.join('tmp', 'spec', 'dese', '4B_2_retention.csv') }
  let(:i3_filepath) { Rails.root.join('tmp', 'spec', 'dese', '4B_2_five_year_grad.csv') }

  let(:filepaths) do
    [i1_filepath, i2_filepath, i3_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext '#run_all' do
    it 'creates a csv file with the scraped data' do
      Dese::FourBTwo.new(filepaths:).run_all
      expect(i1_filepath).to exist
      expect(i2_filepath).to exist
      expect(i3_filepath).to exist
    end

    it 'has the correct headers for i1' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '# in Cohort', '% Graduated', '% Still in School', '% Non-Grad Completers', '% H.S. Equiv.',
                             '% Dropped Out', "% Permanently Excluded\n"]
    end

    it 'has the correct headers for i2' do
      headers = File.open(i2_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '# Enrolled', '# Retained', '% Retained', '01', '02', '03', '04', '05', '06', '07', '08', '09',
                             '10', '11', "12\n"]
    end

    it 'has the correct headers for i3' do
      headers = File.open(i3_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '# in Cohort', '% Graduated', '% Still in School', '% Non-Grad Completers', '% H.S. Equiv.',
                             '% Dropped Out', "% Permanently Excluded\n"]
    end
    it 'has the right likert score results for a-degr-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-degr-i1' && row['Academic Year'] == '2020-21'

        likert_score = row['Likert Score']
        likert_score == 'NA' ? likert_score : likert_score.to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.94, 4.69, 4.66, 4.94, 4.93, 4.63, 4.68, 4.29, 4.6, 4.9, 3.43, 4.84, 4.8, 4.86,
                                      4.93, 3.62, 4.83, 3.4, 4.7, 4.62]
    end

    it 'has the right likert score results for a-degr-i2' do
      results = CSV.parse(File.read(i2_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-degr-i2' && row['Academic Year'] == '2020-21'

        likert_score = row['Likert Score']
        likert_score == 'NA' ? likert_score : likert_score.to_f
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
                                      5.0, 5.0, 5.0, 5.0]
    end

    it 'has the right likert score results for a-degr-i3' do
      results = CSV.parse(File.read(i3_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-degr-i3' && row['Academic Year'] == '2019-20'

        likert_score = row['Likert Score']
        likert_score == 'NA' ? likert_score : likert_score.to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.55, 4.47, 4.5, 4.65, 4.71, 4.38, 4.51, 3.22, 4.44, 4.55, 4.57, 4.59, 4.58,
                                      4.67, 4.04, 4.33, 4.07, 4.48, 4.5, 4.52]
    end
  end
end
