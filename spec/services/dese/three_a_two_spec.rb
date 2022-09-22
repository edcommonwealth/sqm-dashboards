require 'rails_helper'
require 'fileutils'
require 'csv'
require "#{Rails.root}/app/lib/seeder"

RSpec.describe Dese::ThreeATwo do
  let(:seeder) { Seeder.new }
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

  let(:enrollment_filepath) { Rails.root.join('tmp', 'spec', 'dese', '3A_2_enrollment.csv') }
  let(:i1_filepath) { Rails.root.join('tmp', 'spec', 'dese', '3A_2_age_staffing.csv') }
  let(:i4_filepath) { Rails.root.join('tmp', 'spec', 'dese', '3A_2_grade_subject_staffing.csv') }

  let(:filepaths) do
    [enrollment_filepath, i1_filepath, i4_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext '#run_all' do
    it 'creates a csv file with the scraped data' do
      seeder.seed_districts_and_schools sample_districts_and_schools_csv
      Dese::ThreeATwo.new(filepaths:).run_all
      expect(enrollment_filepath).to exist
      expect(i1_filepath).to exist
      expect(i4_filepath).to exist
    end

    it 'has the correct headers for enrollements' do
      headers = File.open(enrollment_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'PK', 'K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'SP', "Total\n"]
    end

    it 'has the correct headers for a-sust-i1' do
      headers = File.open(i1_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             '<26 yrs (# )', '26-32 yrs (#)', '33-40 yrs (#)', '41-48 yrs (#)',
                             '49-56 yrs (#)', '57-64 yrs (#)', 'Over 64 yrs (#)', 'FTE Count',
                             'Student Count', "Student to Guidance Counselor ratio\n"]
    end

    it 'has the correct headers for a-sust-i4' do
      headers = File.open(i4_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                             'PK-2 (# )', '3-5 (# )', '6-8 (# )', '9-12 (# )', 'Multiple Grades (# )', 'All Grades (# )', 'FTE Count',
                             'Student Count', "Student to Art Teacher ratio\n"]
    end

    it 'has the right likert score results for a-sust-i1' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-sust-i1' && row['Academic Year'] == '2021-22'

        row['Likert Score'].to_f unless row['Likert Score'] == 'NA'
      end.flatten.compact

      expect(results.take(20)).to eq [4.96, 1.0, 5.0, 1.0, 5.0, 4.21, 4.45, 4.15, 3.17, 5.0, 4.48, 3.62, 5.0, 1.0, 1.0,
                                      4.44, 3.8, 1.0, 1.0, 1.0]
    end

    it 'has the right likert score results for a-sust-i2' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-sust-i2' && row['Academic Year'] == '2021-22'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [1.0, 1.0, 1.0, 2.82, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                                      1.0, 1.0, 1.0, 1.0]
    end

    it 'has the right likert score results for a-sust-i3' do
      results = CSV.parse(File.read(i1_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-sust-i3' && row['Academic Year'] == '2021-22'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [2.03, 5.0, 1.0, 3.74, 5.0, 4.38, 1.0, 1.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
                                      4.74, 3.5, 2.76, 1.0, 5.0]
    end

    it 'has the right likert score results for a-sust-i4' do
      results = CSV.parse(File.read(i4_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-sust-i4' && row['Academic Year'] == '2021-22'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [5.0, 1.0, 5.0, 5.0, 4.14, 5.0, 5.0, 5.0, 5.0, 5.0, 1.0, 5.0, 5.0, 5.0, 5.0, 5.0,
                                      5.0, 4.82, 5.0, 1.0]
    end
  end

  xcontext 'student_count' do
    it 'returns the right enrollment count for a school and year' do
      to_check = [[4_450_105, '2021-22', 1426],
                  [3_500_003, '2020-21', 489],
                  [2_430_315, '2020-21', 616],
                  [3_260_055, '2020-21', 290]]
      three_a_two = Dese::ThreeATwo.new
      three_a_two.scrape_enrollments(filepath: enrollment_filepath)
      to_check.each do |items|
        expect(three_a_two.student_count(filepath: enrollment_filepath, dese_id: items[0],
                                         year: items[1])).to be items[2]
      end

      three_a_two.browser.close
    end
  end

  private

  def sample_districts_and_schools_csv
    Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
  end
end
