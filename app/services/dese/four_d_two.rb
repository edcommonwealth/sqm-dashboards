require 'watir'

module Dese
  class FourDTwo
    include Dese::Scraper
    attr_reader :filepath

    def initialize(filepath: Rails.root.join('data', 'admin_data', 'dese', '4D_2_cte_courses.csv'))
      @filepath = filepath
    end

    def run_all
      headers = [ 'Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID', "Admin Grade 9", "Grade 10", "Grade 11", "Grade 12", "SP", "Total", "% of All Students", "# of All Students"]
      write_headers(filepath: @filepath, headers:)

      run_a_cppm_i2(filepath: @filepath)
    end

    def run_a_cppm_i2(filepath:)
      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/PathwaysProgramsEnrollmentbyGrade.aspx"
        range = academic_year.range
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range }
        submit_id = "btnViewReport"
        calculation = lambda { |headers, items|
          percent_enrolled = items[headers['% of All Students']].to_f
          benchmark = 26.7
          percent_enrolled * 4 / benchmark if percent_enrolled.present? && items[headers['% of All Students']] != ""
        }
        admin_data_item_id = "a-cppm-i2"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
