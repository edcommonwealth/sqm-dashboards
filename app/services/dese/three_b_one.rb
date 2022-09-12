require 'watir'
require 'csv'

module Dese
  class ThreeBOne
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', 'three_b_one_masscore.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', 'three_b_one_advcoursecomprate.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', 'three_b_one_ap.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Graduated', '# Completed MassCore', '% Completed MassCore']
      write_headers(filepath:, headers:)

      run_a_curv_i1(filepath:)

      filepath = filepaths[1]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Grade 11 and 12 Students', '# Students Completing Advanced', '% Students Completing Advanced',
                 '% ELA', '% Math', '% Science and Technology', '% Computer and Information Science',
                 '% History and Social Sciences', '% Arts', '% All Other Subjects', '% All Other Subjects']
      write_headers(filepath:, headers:)
      run_a_curv_i2(filepath:)

      filepath = filepaths[2]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'Tests Taken', 'Score=1', 'Score=2', 'Score=3', 'Score=4', 'Score=5', '% Score 1-2', '% Score 3-5']
      write_headers(filepath:, headers:)
      run_a_curv_i3(filepath:)

      browser.close
    end

    def run_a_curv_i1(filepath:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/masscore.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          completed_index = headers['% Completed MassCore']
          percent_completed = items[completed_index].to_f
          benchmark = 90
          percent_completed * 4 / benchmark if completed_index.present? && !items[completed_index] != ''
        }
        admin_data_item_id = 'a-curv-i1'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_curv_i2(filepath:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/advcoursecomprate.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          completed_index = headers['% Students Completing Advanced']
          percent_completed = items[completed_index].to_f
          benchmark = 30
          percent_completed * 4 / benchmark if completed_index.present? && !items[completed_index] != ''
        }
        admin_data_item_id = 'a-curv-i2'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_curv_i3(filepath:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/ap.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'ctl00_ContentPlaceHolder1_btnViewReport'
        calculation = lambda { |headers, items|
          completed_index = headers['% Score 3-5']
          percent_score = items[completed_index].to_f
          benchmark = 20
          percent_score * 4 / benchmark if completed_index.present? && !items[completed_index] != ''
        }
        admin_data_item_id = 'a-curv-i3'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
