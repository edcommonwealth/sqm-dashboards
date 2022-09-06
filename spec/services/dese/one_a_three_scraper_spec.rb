require 'rails_helper'
require 'fileutils'
require 'csv'

RSpec.describe Dese::OneAThreeScraper do
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
  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'one_a_three.csv') }
  let(:i3_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'one_a_three_teachers_of_color.csv') }

  let(:filepaths) do
    [i1_filepath, i3_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  context 'Creating a new Scraper' do
    it 'creates a csv file with the scraped data' do
      Dese::OneAThreeScraper.new(filepaths:)
      expect(i1_filepath).to exist
    end

    it 'has the correct headers' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')
      expect(headers).to eq ['Raw likert calculation', 'Likert Score',
                             'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'Principal Total', 'Principal # Retained', 'Principal % Retained',
                             'Teacher Total', 'Teacher # Retained', "Teacher % Retained\n"]
    end

    it 'has the right likert score results for a-pcom-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        row['Likert Score'].to_f
      end

      expect(results.take(20)).to eq [4.1, 4.71, 4.37, 4.07, 4.22, 3.36, 3.36, 4.27, 3.92, 3.84, 4.71, 4.5, 4.08,
                                      3.86, 4.46, 3.68, 3.7, 3.57, 4.1, 4.71]
    end
    it 'has the right likert score results for a-exp-i3' do
      results = CSV.parse(File.read(i3_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-pcom-i3' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [2.91, 1, 2.12, 2.63, 1, 1, 5, 1.16, 1.47, 1.44, 2.66, 4.22, 1, 1.38, 4.19, 1.78,
                                      1, 1, 2.06, 1.44]
    end
  end
end
