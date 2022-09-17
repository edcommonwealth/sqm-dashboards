require 'watir'
require 'csv'

module Dese
  class FourAOne
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '4A_1_grade_nine_course_pass.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Grade Nine Students', '# Passing All Courses', '% Passing All Courses']
      write_headers(filepath:, headers:)

      run_a_ovpe_i1(filepath:)

      browser.close
    end

    def run_a_ovpe_i1(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-ovpe-i1'
        url = 'https://profiles.doe.mass.edu/statereport/gradeninecoursepass.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          passing_index = headers['% Passing All Courses']
          return 'NA' if items[passing_index] == '' || items[passing_index].strip == '.0'

          percent_passing = items[passing_index].to_f
          benchmark = 95
          percent_passing * 4 / benchmark if passing_index.present?
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
