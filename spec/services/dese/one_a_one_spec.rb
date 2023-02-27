require 'rails_helper'
require 'fileutils'

RSpec.describe Dese::OneAOne do
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
  let(:filepath) { Rails.root.join('tmp', 'spec', 'dese', '1A_1_teacher_data.csv') }
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext 'Creating a new Scraper' do
    it 'creates a csv file with the scraped data' do
      Dese::OneAOne.new(filepath:)
      expect(filepath).to exist
    end

    it 'has the correct headers' do
      headers = File.open(filepath) do |file|
        headers = file.first
      end.split(',')
      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year',
                             'School Name', 'DESE ID', 'Total # of Teachers(FTE)', 'Percent of Teachers Licensed',
                             'Student/Teacher Ratio', 'Percent of Experienced Teachers',
                             'Percent of Teachers without Waiver or Provisional License', "Percent Teaching in-field\n"]
    end

    it 'has the right likert score results for a-exp-i1' do
      results = CSV.parse(File.read(filepath), headers: true).map do |row|
        row['Likert Score'].to_f
      end

      expect(results.take(20)).to eq [3.7, 4, 4.31, 3.95, 3.99, 3.69, 1.69,
                                      4.5, 4.21, 4.1, 5, 4.2, 4.51, 3.97, 4.35,
                                      4.38, 4.08, 4, 4.12, 5]
    end

    it 'has the right likert score results for a-exp-i3' do
      results = CSV.parse(File.read(filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-exp-i3' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [3.68, 4.21, 4.01, 3.73, 4.21, 4.21, 2.48, 4.06, 4.21, 4.21, 4.21, 4.21, 4.21,
                                      4.21, 4.21, 4.1, 4, 4.07, 3.32, 4.21]
    end

    it 'has the latest academic_year' do
      academic_year = CSV.parse(File.read(filepath), headers: true).map do |row|
        break row['Academic Year']
      end

      expect(academic_year).to eq '2021-22'
    end
    it 'has both admin data items in the file' do
      results = CSV.parse(File.read(filepath), headers: true).map do |row|
        row['Admin Data Item']
      end

      expect(results.uniq).to eq %w[a-exp-i1 a-exp-i3]
    end
  end
end
