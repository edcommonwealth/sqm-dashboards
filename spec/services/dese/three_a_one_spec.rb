require 'rails_helper'
require 'fileutils'

RSpec.describe Dese::ThreeAOne do
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

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '3A_1_average_class_size.csv') }

  let(:filepaths) do
    [i1_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext 'Creating a new Scraper' do
    it 'creates a csv file with the scraped data' do
      Dese::ThreeAOne.new(filepaths:).run_all
      expect(i1_filepath).to exist
    end

    it 'has the correct headers' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'Total # of Classes', 'Average Class Size', 'Number of Students', 'Female %', 'Male %',
                             'English Language Learner %', 'Students with Disabilities %', "Economically Disadvantaged %\n"]
    end

    it 'has the right likert score results for a-reso-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-reso-i1' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.22, 5.0, 4.58, 3.46, 3.98, 3.68, 4.06, 4.84, 4.42, 4.66, 5.0, 4.6, 4.26, 4.46,
                                      4.2, 4.66, 5.0, 4.6, 4.28, 5.0]
    end
  end
end
