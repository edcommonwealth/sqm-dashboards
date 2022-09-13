require 'watir'
require 'csv'

module Dese
  class TwoCOne
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '2C_1_attendance.csv')])
      @filepaths = filepaths
    end

    def run_all
      write_a_vale_i1_headers
      run_a_vale_i1
      run_a_vale_i2

      browser.close
    end

    def write_a_vale_i1_headers
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'Attendance Rate', 'Average # of Absences', 'Absent 10 or more days', 'Chronically Absent (10% or more)',
                 'Chronically Absent (20% or more)', 'Unexcused > 9 days']
      write_headers(filepath:, headers:)
    end

    def run_a_vale_i1
      run do |academic_year|
        admin_data_item_id = 'a-vale-i1'
        url = 'https://profiles.doe.mass.edu/statereport/attendance.aspx'
        range = case academic_year.range
                when '2021-22', '2020-21'
                  "#{academic_year.range} (End of year)"
                else
                  academic_year.range
                end
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          absence_index = headers['Chronically Absent (10% or more)']
          benchmark = 10
          absence_rate = items[absence_index].to_f
          if absence_index.present? && !items[absence_index].blank?
            ((benchmark - absence_rate) + benchmark) * 4 / benchmark
          end
        }
        Prerequisites.new(filepaths[0], url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_vale_i2
      run do |academic_year|
        admin_data_item_id = 'a-vale-i2'
        url = 'https://profiles.doe.mass.edu/statereport/attendance.aspx'
        range = case academic_year.range
                when '2021-22', '2020-21'
                  "#{academic_year.range} (End of year)"
                else
                  academic_year.range
                end
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          attendance = headers[' Attendance Rate ']
          benchmark = 90
          items[attendance].to_f * 4 / benchmark if attendance.present?
        }
        Prerequisites.new(filepaths[0], url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
