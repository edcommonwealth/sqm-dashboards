require 'rails_helper'
require 'fileutils'

RSpec.describe Dese::TwoAOne do
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

  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '2A_1_students_suspended.csv') }
  let(:i3_filepath) { Rails.root.join('tmp', 'spec', 'dese', '2A_1_students_disciplined.csv') }

  let(:filepaths) do
    [i1_filepath, i3_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext 'Creating a new Scraper' do
    it 'creates a csv file with the scraped data' do
      Dese::TwoAOne.new(filepaths:).run_all
      expect(i1_filepath).to exist
    end

    it 'has the correct headers' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'Students', 'Students Disciplined',
                             '% In-School Suspension', '% Out-of-School Suspension', '% Expulsion', '% Removed to Alternate Setting',
                             '% Emergency Removal', '% Students with a School-Based Arrest', "% Students with a Law Enforcement Referral\n"]
    end

    it 'has the right likert score results for a-phys-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        row['Likert Score'].to_f unless row['Likert Score'] == 'NA' || row['Likert Score'].nil?
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
                                      5.0, 5.0, 5.0, 5.0]
    end
    it 'has the right likert score results for a-exp-i3' do
      results = CSV.parse(File.read(i3_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-phys-i3' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f unless row['Likert Score'] == 'NA' || row['Likert Score'].nil?
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 3.6, 5.0,
                                      5.0, 5.0, 5.0, 5.0]
    end
  end
end
