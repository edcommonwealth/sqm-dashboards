require 'watir'
require 'csv'

module Dese
  class FiveDTwo
    include Dese::Scraper
    include Dese::Enrollments
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', 'enrollments.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '5D_2_age_staffing.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      scrape_enrollments(filepath:)

      filepath = filepaths[1]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '<26 yrs (# )', '26-32 yrs (#)', '33-40 yrs (#)', '41-48 yrs (#)', '49-56 yrs (#)', '57-64 yrs (#)', 'Over 64 yrs (#)', 'FTE Count']
      write_headers(filepath:, headers:)

      run_a_phya_i1(filepath:)

      browser.close
    end

    def run_a_phya_i1(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-phya-i1'
        url = 'https://profiles.doe.mass.edu/statereport/agestaffing.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddJobClassification' => 'School Nurse -- Non-Special Education' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          nurse_index = headers['FTE Count']
          return 'NA' if items[nurse_index] == '' || items[nurse_index].strip == '.0'

          nurse_count = items[nurse_index].to_f
          benchmark = 750
          nurse_count * 4 / benchmark if nurse_index.present?

          dese_id = items[headers['School Code']].to_i
          num_of_students = student_count(filepath: filepaths[0], dese_id:, year: academic_year.range) || 0
          items << num_of_students
          items << (num_of_students / nurse_count)
          ((benchmark - (num_of_students / nurse_count)) + benchmark) * 4 / benchmark
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
