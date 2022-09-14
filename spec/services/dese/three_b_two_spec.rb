require 'rails_helper'
require 'fileutils'
require 'csv'

RSpec.describe Dese::ThreeBTwo do
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

  let(:enrollment_filepath) { Rails.root.join('tmp', 'spec', 'dese', 'enrollments.csv') }
  let(:teacher_race_filepath) { Rails.root.join('tmp', 'spec', 'dese', '3B_2_teacher_by_race_and_gender.csv') }
  let(:student_race_filepath) { Rails.root.join('tmp', 'spec', 'dese', '3B_2_student_by_race_and_gender.csv') }

  let(:filepaths) do
    [enrollment_filepath, teacher_race_filepath, student_race_filepath]
  end
  before do
    FileUtils.mkdir_p 'tmp/spec/dese'
  end

  before :each do
    academic_years
  end

  xcontext '#run_all' do
    it 'creates a csv file with the scraped data' do
      Dese::ThreeBTwo.new(filepaths:).run_all
      expect(teacher_race_filepath).to exist
      expect(student_race_filepath).to exist
    end

    it 'has the correct headers for teacher demographic information' do
      headers = File.open(teacher_race_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'Teachers of color (#)', 'School Name', 'DESE ID',
                             'African American (#)', 'Asian (#)', 'Hispanic (#)', 'White (#)', 'Native American (#)',
                             'Native Hawaiian Pacific Islander (#)', 'Multi-Race Non-Hispanic (#)', 'Females (#)',
                             'Males (#)', "FTE Count\n"]
    end
    it 'has the correct headers for student demographic information' do
      pending 'need feedback from peter'
      headers = File.open(student_race_filepath) do |file|
        headers = file.first
      end.split(',')

      expect(headers).to eq ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'Non-White Teachers', 'Non-White Students', 'School Name', 'DESE ID',
                             'African American', 'Asian', 'Hispanic', 'White', 'Native American',
                             'Native Hawaiian or Pacific Islander', 'Multi-Race or Non-Hispanic', 'Males',
                             'Females', 'Non-Binary', "Students of color (%)\n"]
    end

    it 'has the right likert score results for a-cure-i1' do
      pending 'not yet implemented'
      results = CSV.parse(File.read(student_race_filepath), headers: true).map do |row|
        next unless row['Admin Data Item'] == 'a-cure-i1' && row['Academic Year'] == '2020-21'

        row['Likert Score'].to_f
      end.flatten.compact

      expect(results.take(20)).to eq [4.44, 4.44, 3.33, 3.83, 4.44, 3.6, 4.44, 4.44, 1, 4.44, 4.44, 4.44, 4.44, 3.89,
                                      4.44, 4.44, 4.44, 4.44, 4.01, 3.92]
    end
  end
end
