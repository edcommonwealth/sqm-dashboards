require 'watir'
require 'csv'

module Dese
  class FiveCOne
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '5C_1_art_course.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'K', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
                 '11', '12', 'All Grades', 'Total Students']
      write_headers(filepath:, headers:)

      run_a_picp_i1(filepath:)

      browser.close
    end

    def run_a_picp_i1(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-picp-i1'
        url = 'https://profiles.doe.mass.edu/statereport/artcourse.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddView' => 'Percent' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          percent_graduated_index = headers['All Grades'] - 1
          if items[percent_graduated_index].nil? || items[percent_graduated_index] == '' || items[percent_graduated_index].strip == '.0'
            return 'NA'
          end

          percent_passing = items[percent_graduated_index].to_f
          benchmark = 77.5
          percent_passing * 4 / benchmark if percent_graduated_index.present?
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
