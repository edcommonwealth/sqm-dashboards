require 'watir'
require 'csv'

module Dese
  class OneAThree
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '1A_3_staffing_retention.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '1A_3_teachers_of_color.csv')])
      @filepaths = filepaths
    end

    def run_all
      run_a_pcom_i1
      run_a_pcom_i3

      browser.close
    end

    def run_a_pcom_i1
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'Principal Total', 'Principal # Retained', 'Principal % Retained',
                 'Teacher Total', 'Teacher # Retained', 'Teacher % Retained']
      write_headers(filepath:, headers:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/staffingRetentionRates.aspx'
        range = "#{academic_year.range.split('-').last.to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          retained_teachers = headers['% Retained']
          items[retained_teachers].to_f * 4 / 85 if retained_teachers.present?
        }
        admin_data_item_id = 'a-pcom-i1'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_pcom_i3
      filepath = filepaths[1]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'African American (%)', 'Asian (%)', 'Hispanic (%)', 'White (%)', 'Native Hawaiian, Pacific Islander (%)',
                 'Multi-Race,Non-Hispanic (%)', 'Females (%)', 'Males (%)', 'FTE Count']
      write_headers(filepath:, headers:)

      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/teacherbyracegender.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddDisplay' => 'Percentages' }
        submit_id = 'ctl00_ContentPlaceHolder1_btnViewReport'
        calculation = lambda { |headers, items|
          white = headers['White (%)']
          result = ((100 - items[white].to_f) * 4) / 12.8 if white.present?

          result = 1 if result < 1
          result
        }
        admin_data_item_id = 'a-pcom-i3'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
