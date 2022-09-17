require 'watir'
require 'csv'

module Dese
  class FourBTwo
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '4B_2_four_year_grad.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '4B_2_retention.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '4B_2_five_year_grad.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# in Cohort', '% Graduated', '% Still in School', '% Non-Grad Completers', '% H.S. Equiv.',
                 '% Dropped Out', '% Permanently Excluded']
      write_headers(filepath:, headers:)

      run_a_degr_i1(filepath:)

      filepath = filepaths[1]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Enrolled', '# Retained', '% Retained', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
                 '11', '12']
      write_headers(filepath:, headers:)

      run_a_degr_i2(filepath:)

      filepath = filepaths[2]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# in Cohort', '% Graduated', '% Still in School', '% Non-Grad Completers', '% H.S. Equiv.',
                 '% Dropped Out', '% Permanently Excluded']
      write_headers(filepath:, headers:)

      run_a_degr_i3(filepath:)
      browser.close
    end

    def run_a_degr_i1(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-degr-i1'
        url = 'https://profiles.doe.mass.edu/statereport/gradrates.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddRateType' => '4yr Grad' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          percent_graduated_index = headers['% Graduated']
          return 'NA' if items[percent_graduated_index] == '' || items[percent_graduated_index].strip == '.0'

          percent_passing = items[percent_graduated_index].to_f
          benchmark = 80
          percent_passing * 4 / benchmark if percent_graduated_index.present?
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_degr_i2(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-degr-i2'
        url = 'https://profiles.doe.mass.edu/statereport/retention.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddView' => 'Percent' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          retained_index = headers['% Retained']
          return 'NA' if items[retained_index] == '' || items[retained_index].strip == '.0'

          percent_retained = items[retained_index].to_f
          benchmark = 2
          ((benchmark - percent_retained) + benchmark) * 4 / benchmark if retained_index.present?
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_degr_i3(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-degr-i3'
        url = 'https://profiles.doe.mass.edu/statereport/gradrates.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddRateType' => '5yr Grad' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          percent_graduated_index = headers['% Graduated']
          return 'NA' if items[percent_graduated_index] == '' || items[percent_graduated_index].strip == '.0'

          percent_passing = items[percent_graduated_index].to_f
          benchmark = 85
          percent_passing * 4 / benchmark if percent_graduated_index.present?
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
