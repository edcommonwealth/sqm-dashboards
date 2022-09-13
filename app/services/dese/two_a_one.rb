require 'watir'
require 'csv'

module Dese
  class TwoAOne
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '2A_1_students_suspended.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '2A_1_students_disciplined.csv')])
      @filepaths = filepaths
    end

    def run_all
      run_a_phys_i1
      run_a_phys_i3

      browser.close
    end

    def run_a_phys_i1
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'Students', 'Students Disciplined', '% In-School Suspension', '% Out-of-School Suspension', '% Expulsion', '% Removed to Alternate Setting',
                 '% Emergency Removal', '% Students with a School-Based Arrest', '% Students with a Law Enforcement Referral']
      write_headers(filepath:, headers:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/ssdr.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'ctl00_ContentPlaceHolder1_btnViewReport'
        calculation = lambda { |headers, items|
          suspensions_index = headers['% Out-of-School Suspension']
          benchmark = 5.27
          suspension_rate = items[suspensions_index].to_f
          if suspensions_index.present? && items[suspensions_index] != ''
            ((benchmark - suspension_rate) + benchmark) * 4 / 5.27
          end
        }
        admin_data_item_id = 'a-phys-i1'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_phys_i3
      filepath = filepaths[1]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'Students', 'Students Disciplined', '% 1 Day', '% 2 to 3 Days', '% 4 to 7 Days', '% 8 to 10 Days', '% > 10 Days']
      write_headers(filepath:, headers:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/ssdr_days_missed.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'ctl00_ContentPlaceHolder1_btnViewReport'
        calculation = lambda { |headers, items|
          days_missed_index = headers['% > 10 Days']
          benchmark = 1
          missed_days = items[days_missed_index].to_f
          if days_missed_index.present? && items[days_missed_index] != ''
            ((benchmark - missed_days) + benchmark) * 4 / benchmark
          end
        }
        admin_data_item_id = 'a-phys-i3'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
