require 'watir'
require 'csv'

module Dese
  class ThreeATwo
    include Dese::Scraper
    include Dese::Enrollments
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', 'enrollments.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '3A_2_age_staffing.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', '3A_2_grade_subject_staffing.csv')])

      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      scrape_enrollments(filepath:)

      filepath = filepaths[1]
      write_a_sust_i1_headers(filepath:)
      run_a_sust_i1(filepath:)
      run_a_sust_i2(filepath:)
      run_a_sust_i3(filepath:)

      filepath = filepaths[2]
      write_a_sust_i4_headers(filepath:)
      run_a_sust_i4(filepath:)

      browser.close
    end

    def write_a_sust_i1_headers(filepath:)
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '<26 yrs (# )', '26-32 yrs (#)', '33-40 yrs (#)', '41-48 yrs (#)',
                 '49-56 yrs (#)', '57-64 yrs (#)', 'Over 64 yrs (#)', 'FTE Count',
                 'Student Count', 'Student to Guidance Counselor ratio']

      write_headers(filepath:, headers:)
    end

    def write_a_sust_i4_headers(filepath:)
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 'PK-2 (# )', '3-5 (# )', '6-8 (# )', '9-12 (# )', 'Multiple Grades (# )', 'All Grades (# )', 'FTE Count',
                 'Student Count', 'Student to Art Teacher ratio']

      write_headers(filepath:, headers:)
    end

    def run_a_sust_i1(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-sust-i1'
        url = 'https://profiles.doe.mass.edu/statereport/agestaffing.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddJobClassification' => 'Guidance Counselor' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          fte_index = headers['FTE Count']
          num_of_guidance_counselors = items[fte_index].to_f
          dese_id = items[headers['School Code']].to_i
          school = School.find_by_dese_id(dese_id)

          return 'NA' unless school.present? && school.is_hs?

          num_of_students = student_count(filepath: filepaths[0], dese_id:, year: academic_year.range) || 0
          items << num_of_students
          benchmark = 250
          if fte_index.present? && !items[fte_index] != ''
            result = ((benchmark - (num_of_students / num_of_guidance_counselors)) + benchmark) * 4 / benchmark
          end
          items << (num_of_students / num_of_guidance_counselors)
          result
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_sust_i2(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-sust-i2'
        url = 'https://profiles.doe.mass.edu/statereport/agestaffing.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddJobClassification' => 'School Psychologist -- Non-Special Education' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          fte_index = headers['FTE Count']
          num_of_psychologists = items[fte_index].to_f
          dese_id = items[headers['School Code']].to_i
          num_of_students = student_count(filepath: filepaths[0], dese_id:, year: academic_year.range) || 0
          items << num_of_students
          benchmark = 250
          if fte_index.present? && !items[fte_index] != ''
            result = ((benchmark - (num_of_students / num_of_psychologists)) + benchmark) * 4 / benchmark
          end

          items << (num_of_students / num_of_psychologists)
          result
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_sust_i3(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-sust-i3'
        url = 'https://profiles.doe.mass.edu/statereport/agestaffing.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddJobClassification' => 'Paraprofessional' }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          fte_index = headers['FTE Count']
          num_of_paraprofessionals = items[fte_index].to_f
          dese_id = items[headers['School Code']].to_i
          num_of_students = student_count(filepath: filepaths[0], dese_id:, year: academic_year.range) || 0
          items << num_of_students
          benchmark = 43.4
          if fte_index.present? && !items[fte_index] != ''
            result = ((benchmark - (num_of_students / num_of_paraprofessionals)) + benchmark) * 4 / benchmark
          end

          items << (num_of_students / num_of_paraprofessionals)
          result
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_sust_i4(filepath:)
      run do |academic_year|
        admin_data_item_id = 'a-sust-i4'
        url = 'https://profiles.doe.mass.edu/statereport/gradesubjectstaffing.aspx'
        range = academic_year.range

        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range,
                      'ctl00_ContentPlaceHolder1_ddDisplay' => 'Full-time Equivalents',
                      'ctl00_ContentPlaceHolder1_ddSubject' => 'Arts' }
        submit_id = 'btnViewReport'
        calculation = lambda { |_headers, items|
          num_of_art_teachers = items.last.to_f
          dese_id = items[1].to_i
          num_of_students = student_count(filepath: filepaths[0], dese_id:, year: academic_year.range) || 0
          items << num_of_students
          benchmark = 500
          if num_of_art_teachers.present?
            result = ((benchmark - (num_of_students / num_of_art_teachers)) + benchmark) * 4 / benchmark
          end

          items << (num_of_students / num_of_art_teachers)
          result
        }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end
  end
end
