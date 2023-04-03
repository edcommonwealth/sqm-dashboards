require 'watir'

module Dese
  class Staffing
    include Dese::Scraper
    attr_reader :filepath

    def initialize(filepath: Rails.root.join('data', 'staffing', 'staffing.csv'))
      @filepath = filepath
    end

    def run_all
      scrape_staffing(filepath:)
    end

    def scrape_staffing(filepath:)
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year',
                 'School Name', 'DESE ID',
                 'PK-2 (#)', '3-5 (#)', '6-8 (#)', '9-12 (#)', 'Multiple Grades (#)',
                 'All Grades (#)', 'FTE Count']
      write_headers(filepath:, headers:)
      run do |academic_year|
        admin_data_item_id = 'NA'
        url = 'https://profiles.doe.mass.edu/statereport/gradesubjectstaffing.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddDisplay' => 'Full-time Equivalents' }
        submit_id = 'btnViewReport'
        calculation = ->(_headers, _items) { 'NA' }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
