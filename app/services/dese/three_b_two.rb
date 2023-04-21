require 'watir'
require 'csv'

module Dese
  class ThreeBTwo
    include Dese::Scraper
    include Dese::Enrollments
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '3B_2_teacher_by_race_and_gender.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '3B_2_student_by_race_and_gender.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'Teachers of color (%)', 'School Name', 'DESE ID',
                 'African American (%)', 'Asian (%)', 'Hispanic (%)', 'White (%)', 'Native American (%)',
                 'Native Hawaiian Pacific Islander (%)', 'Multi-Race Non-Hispanic (%)', 'Females (%)',
                 'Males (%)', 'FTE Count']
      write_headers(filepath:, headers:)
      run_teacher_demographics(filepath:)

      filepath = filepaths[1]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'Non-White Teachers %', 'Non-White Students %', 'School Name', 'DESE ID',
                 'African American', 'Asian', 'Hispanic', 'White', 'Native American',
                 'Native Hawaiian or Pacific Islander', 'Multi-Race or Non-Hispanic', 'Males',
                 'Females', 'Non-Binary', 'Students of color (%)']
      write_headers(filepath:, headers:)
      run_student_demographics(filepath:)

      browser.close
    end

    def run_teacher_demographics(filepath:)
      run do |academic_year|
        admin_data_item_id = ''
        url = 'https://profiles.doe.mass.edu/statereport/teacherbyracegender.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddDisplay' => 'Percentages',
                      'ctl00_ContentPlaceHolder1_ddClassification' => 'Teacher' }
        submit_id = 'ctl00_ContentPlaceHolder1_btnViewReport'
        calculation = lambda { |headers, items|
          african_american_index = headers['African American (%)']
          african_american_number = items[african_american_index].to_f

          asian_index = headers['Asian (%)']
          asian_number = items[asian_index].to_f

          hispanic_index = headers['Hispanic (%)']
          hispanic_number = items[hispanic_index].to_f

          native_american_index = headers['Native American (%)']
          native_american_number = items[native_american_index].to_f

          native_hawaiian_index = headers['Native Hawaiian, Pacific Islander (%)']
          native_hawaiian_number = items[native_hawaiian_index].to_f

          multi_race_index = headers['Multi-Race,Non-Hispanic (%)']
          multi_race_number = items[multi_race_index].to_f

          non_white_teachers = african_american_number + asian_number + hispanic_number + native_american_number + native_hawaiian_number + multi_race_number
          items.unshift(non_white_teachers)

          non_white_teachers
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def teacher_count(filepath:, dese_id:, year:)
      @teachers ||= {}
      @years_with_data ||= Set.new
      if @teachers.count == 0
        CSV.parse(File.read(filepath), headers: true).map do |row|
          academic_year = row['Academic Year']
          @years_with_data << academic_year
          school_id = row['DESE ID'].to_i
          total = row['Teachers of color (%)'].delete(',')
          total = 'NA' if total == '' || total.nil?
          @teachers[[school_id, academic_year]] = total
        end
      end
      return 'NA' unless @years_with_data.include? year

      @teachers[[dese_id, year]]
    end

    def run_student_demographics(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-cure-i1'
        url = 'https://profiles.doe.mass.edu/statereport/enrollmentbyracegender.aspx'
        range = academic_year.range

        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          white_index = headers['White']
          white_number = items[white_index].to_f
          dese_id = items[headers['School Code']].to_i
          non_white_student_percentage = (100 - white_number).to_f
          items.unshift(non_white_student_percentage)
          count_of_teachers = teacher_count(filepath: filepaths[0], dese_id:, year: academic_year.range)
          return 'NA' if count_of_teachers == 'NA'

          non_white_teacher_percentage = count_of_teachers.to_f
          items.unshift(non_white_teacher_percentage)

          floor = 5
          benchmark = 0.25

          return 1 if non_white_student_percentage.zero? && non_white_teacher_percentage < floor

          if non_white_teacher_percentage >= floor
            parity_index = non_white_teacher_percentage / non_white_student_percentage
            likert_score = parity_index * 4 / benchmark
          else
            likert_score = 1
          end
          likert_score
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
