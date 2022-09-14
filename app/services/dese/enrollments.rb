require 'watir'
require 'csv'

module Dese
  module Enrollments
    include Dese::Scraper
    attr_reader :filepaths

    def scrape_enrollments(filepath:)
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'PK', 'K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'SP', 'Total']
      write_headers(filepath:, headers:)
      run do |academic_year|
        admin_data_item_id = ''
        url = 'https://profiles.doe.mass.edu/statereport/enrollmentbygrade.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = ->(_headers, _items) { 'NA' }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def student_count(filepath:, dese_id:, year:)
      @students ||= {}
      if @students.count == 0
        CSV.parse(File.read(filepath), headers: true).map do |row|
          academic_year = row['Academic Year']
          school_id = row['DESE ID'].to_i
          total = row['Total'].gsub(',', '').to_i
          @students[[school_id, academic_year]] = total
        end
      end
      @students[[dese_id, year]]
    end
  end
end
