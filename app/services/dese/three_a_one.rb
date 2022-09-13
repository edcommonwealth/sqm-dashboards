require 'watir'
require 'csv'

module Dese
  class ThreeAOne
    include Dese::Scraper
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', '3A_1_average_class_size.csv')])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'Total # of Classes', 'Average Class Size', 'Number of Students', 'Female %', 'Male %',
                 'English Language Learner %', 'Students with Disabilities %', 'Economically Disadvantaged %']
      write_headers(filepath:, headers:)

      run_a_reso_i1

      browser.close
    end

    def run_a_reso_i1
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/classsizebygenderpopulation.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          class_size_index = headers['Average Class Size']
          average_class_size = items[class_size_index].to_f
          benchmark = 20
          if class_size_index.present? && !items[class_size_index] != ''
            ((benchmark - average_class_size) + benchmark) * 4 / benchmark
          end
        }
        admin_data_item_id = 'a-reso-i1'
        Prerequisites.new(filepaths[0], url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
