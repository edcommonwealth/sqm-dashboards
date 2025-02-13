require 'watir'
require 'csv'

module Dese
  class ThreeBOne
    include Dese::Scraper
    include Dese::Enrollments
    attr_reader :filepaths

    def initialize(filepaths: [Rails.root.join("data", "admin_data", "dese", "3B_1_masscore.csv"),
                               Rails.root.join("data", "admin_data", "dese", "3B_1_advcoursecomprate.csv"),
                               Rails.root.join("data", "admin_data", "dese", "3B_1_ap.csv"),
                               Rails.root.join("data", "admin_data", "dese", "3B_1_adv_courses.csv"),
                               Rails.root.join("data", "admin_data", "dese", "3B_1_course_ratio.csv"),
                               Rails.root.join("data" , "admin_data", "dese", "3B_1_enrollments_by_race.csv") ,
                               Rails.root.join("data" , "admin_data", "dese", "3B_1_enrollments_by_grade.csv") ,
                               Rails.root.join("data" , "admin_data", "dese", "3B_1_adv_courses_white_students.csv"),
                               Rails.root.join("data" , "admin_data", "dese", "3B_1_students_of_color_completion_rate.csv")

    ])
      @filepaths = filepaths
    end

    def run_all
      filepath = filepaths[0]
      headers = ["Raw likert calculation", "Likert Score", "Admin Data Item", "Academic Year", "School Name", "DESE ID",
                 "# Graduated", "# Completed MassCore", "% Completed MassCore"]
      write_headers(filepath:, headers:)

      run_a_curv_i1(filepath:)

      filepath = filepaths[1]
      headers = ["Raw likert calculation", "Likert Score", "Admin Data Item", "Academic Year", "School Name", "DESE ID",
                 "# Grade 11 and 12 Students", "# Students Completing Advanced", "% Students Completing Advanced",
                 "% ELA", "% Math", "% Science and Technology", "% Computer and Information Science",
                 "% History and Social Sciences", "% Arts", "% All Other Subjects", "% All Other Subjects"]
      write_headers(filepath:, headers:)
      run_a_curv_i2(filepath:)

      filepath = filepaths[2]
      headers = ["Raw likert calculation", "Likert Score", "Admin Data Item", "Academic Year", "School Name", "DESE ID",
                 "Tests Taken", "Score=1", "Score=2", "Score=3", "Score=4", "Score=5", "% Score 1-2", "% Score 3-5"]
      write_headers(filepath:, headers:)
      run_a_curv_i3(filepath:)

      filepath = filepaths[3]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Grade 11 and 12 Students', '# Students Completing Advanced', '% Students Completing Advanced', '% ELA', '% Math', '% Science and Technology', '% Computer and Information Science', '% History and Social Sciences', '% Arts', '% All Other Subjects', 'Ch 74 Secondary Cooperative Program']
      write_headers(filepath:, headers:)
      run_a_curv_i4(filepath:)

      filepath = filepaths[4]
      headers = ["Raw likert calculation", "Likert Score", "Admin Data Item", "Academic Year", "School Name", "DESE ID",
                 "Total # of Classes", "Average Class Size", "Number of Students", "Female %", "Male %", "English Language Learner %", "Students with Disabilities %", "Low Income %"]
      write_headers(filepath:, headers:)
      run_a_curv_i5(filepath:)

      filepath = filepaths[8]
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Grade 11 and 12 Students', '# Students Completing Advanced', '% Students Completing Advanced', '% ELA', '% Math', '% Science and Technology', '% Computer and Information Science', '% History and Social Sciences', '% Arts', '% All Other Subjects', 'Ch 74 Secondary Cooperative Program']
      write_headers(filepath:, headers:)
      run_a_curv_i7(filepath:)

      browser.close
    end

    # We don't need to check to see if this is a high school because the link only lists relevant schools
    def run_a_curv_i1(filepath:)
      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/masscore.aspx"
        range = academic_year.range
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range }
        submit_id = "btnViewReport"
        calculation = lambda { |headers, items|
          completed_index = headers["% Completed MassCore"]
          percent_completed = items[completed_index].to_f
          benchmark = 90
          percent_completed * 4 / benchmark if completed_index.present? && !items[completed_index] != ""
        }
        admin_data_item_id = "a-curv-i1"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    # We don't need to check to see if this is a high school because the link only lists relevant schools
    def run_a_curv_i2(filepath:)
      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/advcoursecomprate.aspx"
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range }
        submit_id = "btnViewReport"
        calculation = lambda { |headers, items|
          completed_index = headers["% Students Completing Advanced"]
          percent_completed = items[completed_index].to_f
          benchmark = 30
          percent_completed * 4 / benchmark if completed_index.present? && !items[completed_index] != ""
        }
        admin_data_item_id = "a-curv-i2"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    # We don't need to check to see if this is a high school because the link only lists relevant schools
    def run_a_curv_i3(filepath:)
      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/ap.aspx"
        range = academic_year.range
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range }
        submit_id = "ctl00_ContentPlaceHolder1_btnViewReport"
        calculation = lambda { |headers, items|
          completed_index = headers["% Score 3-5"]
          percent_score = items[completed_index].to_f
          benchmark = 20
          percent_score * 4 / benchmark if completed_index.present? && !items[completed_index] != ""
        }
        admin_data_item_id = "a-curv-i3"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def scrape_enrollments_by_race(filepath:)
      headers = ["Raw likert calculation", "Likert Score", "Admin Data Item", "Academic Year",  "School Name", "DESE ID",
                 "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Multi-Race, Not Hispanic or Latino",
                 "Native Hawaiian or Other Pacific Islander", "White", "Female",
                 "Male", "Nonbinary"]
      write_headers(filepath:, headers:)
      run do |academic_year|
        admin_data_item_id = ''
        url = 'https://profiles.doe.mass.edu/statereport/enrollmentbyracegender.aspx'
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = ->(_headers, _items) { 'NA' }
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def non_white_student_percentage
      @non_white_student_percentage ||= {}
      if @non_white_student_percentage.count == 0
        CSV.parse(File.read(filepaths[5]), headers: true).map do |row|
          academic_year = row['Academic Year']
          school_id = row['DESE ID'].to_i
          white = row['White'].gsub(',', '').to_i
          @non_white_student_percentage[[school_id, academic_year]] = 100 - white
        end
      end
      @non_white_student_percentage
    end

    def scrape_enrollments_by_grade(filepath:)
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

    def eleventh_and_twelfth_grade_student_count
      @eleventh_and_twelfth_grade_student_count ||= {}
      if @eleventh_and_twelfth_grade_student_count.count == 0
        CSV.parse(File.read(filepaths[6]), headers: true).map do |row|
          academic_year = row['Academic Year']
          school_id = row['DESE ID'].to_i
          eleventh = row['11'].gsub(',', '').to_i
          twelfth = row['12'].gsub(',', '').to_i
          @eleventh_and_twelfth_grade_student_count[[school_id, academic_year]] = eleventh + twelfth
        end
      end
      @eleventh_and_twelfth_grade_student_count
    end


    def scrape_advanced_courses_for_white_students(filepath:)
      headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID',
                 '# Grade 11 and 12 Students', '# Students Completing Advanced', '% Students Completing Advanced', '% ELA', '% Math', '% Science and Technology', '% Computer and Information Science', '% History and Social Sciences', '% Arts', '% All Other Subjects', 'Ch 74 Secondary Cooperative Program']
      write_headers(filepath:, headers:)

      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/advcoursecomprate.aspx"
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range,
                      "ctl00_ContentPlaceHolder1_ddSubgroup" => "White"}
        submit_id = "btnViewReport"
        calculation = lambda { |headers, items| 'NA' }
        admin_data_item_id = "a-curv-i4"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def white_students_in_advanced_courses
      @white_students_in_advanced_courses ||= {}
      if @white_students_in_advanced_courses  .count == 0
        CSV.parse(File.read(filepaths[7]), headers: true).map do |row|
          academic_year = row['Academic Year']
          school_id = row['DESE ID'].to_i
          total_num_students_in_adv_courses = row["# Grade 11 and 12 Students"].to_f

          @white_students_in_advanced_courses[[school_id, academic_year]] = total_num_students_in_adv_courses
        end
      end
      @white_students_in_advanced_courses
    end

    def white_students_completing_advanced_courses
      @white_students_completing_advanced_courses ||= {}
      if @white_students_completing_advanced_courses  .count == 0
        CSV.parse(File.read(filepaths[7]), headers: true).map do |row|
          academic_year = row['Academic Year']
          school_id = row['DESE ID'].to_i
          num_completing_adv_courses = row["# Students Completing Advanced"].to_f

          @white_students_completing_advanced_courses[[school_id, academic_year]] = num_completing_adv_courses
        end
      end
      @white_students_completing_advanced_courses
    end

    # We don't need to check to see if this is a high school because the link only lists relevant schools
    def run_a_curv_i4(filepath:)
      scrape_enrollments_by_race(filepath: filepaths[5])
      scrape_enrollments_by_grade(filepath: filepaths[6])
      scrape_advanced_courses_for_white_students(filepath: filepaths[7])

      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/advcoursecomprate.aspx"
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range }
        submit_id = "btnViewReport"
        calculation = lambda { |headers, items|
          school_id_index = headers["School Code"]
          school_id = items[school_id_index].to_i
          school_name_index = headers["School Name"]
          school_name = items[school_name_index]
          year = academic_year.range

          total_num_students_in_adv_index = headers["# Grade 11 and 12 Students"]
          total_num_students_in_adv_courses = items[total_num_students_in_adv_index].to_f
          return "NA" unless white_students_in_advanced_courses[[school_id, year]]
          non_white_students_in_adv_courses = total_num_students_in_adv_courses - white_students_in_advanced_courses[[school_id, year]]
          return "NA" unless eleventh_and_twelfth_grade_student_count[[school_id, year]]
          count_of_students_in_eleventh_and_twelfth_grade = eleventh_and_twelfth_grade_student_count[[school_id, year]]
          return "NA" unless non_white_student_percentage[[school_id, year]]
          percentage_non_white = non_white_student_percentage[[school_id, year]]
          enrollment_number_of_non_whites = percentage_non_white * count_of_students_in_eleventh_and_twelfth_grade
          percent_non_white_taking_adv_courses = non_white_students_in_adv_courses / count_of_students_in_eleventh_and_twelfth_grade * 100
          benchmark = 35
          percent_non_white_taking_adv_courses * 4 / benchmark
        }
        admin_data_item_id = "a-curv-i4"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def run_a_curv_i5(filepath:)
      run do |academic_year|
        url = 'https://profiles.doe.mass.edu/statereport/classsizebygenderpopulation.aspx'
        range = academic_year.range
        selectors = { 'ctl00_ContentPlaceHolder1_ddReportType' => 'School',
                      'ctl00_ContentPlaceHolder1_ddYear' => range }
        submit_id = 'btnViewReport'
        calculation = lambda { |headers, items|
          school_id = items[headers["School Code"]].to_i
          school_name = items[headers["School Name"]]

          return "NA" unless is_hs?(school_id:, school_name:)

          classes_index = headers["Total # of Classes"]
          num_classes = items[classes_index].gsub(",", "").to_f
          students_index = headers["Number of Students"]
          num_students = items[students_index].gsub(",", "").to_f
          benchmark = 2.04

          ((benchmark - (num_students / num_classes)) + benchmark) * 4 / benchmark
        }
        admin_data_item_id = 'a-curv-i5'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    # We don't need to check to see if this is a high school because the link only lists relevant schools
    def run_a_curv_i7(filepath:)
      scrape_advanced_courses_for_white_students(filepath: filepaths[7])

      run do |academic_year|
        url = "https://profiles.doe.mass.edu/statereport/advcoursecomprate.aspx"
        range = "#{academic_year.range.split('-')[1].to_i + 2000}"
        selectors = { "ctl00_ContentPlaceHolder1_ddReportType" => "School",
                      "ctl00_ContentPlaceHolder1_ddYear" => range }
        submit_id = "btnViewReport"
        calculation = lambda { |headers, items|
          school_id_index = headers["School Code"]
          school_id = items[school_id_index].to_i
          school_name_index = headers["School Name"]
          school_name = items[school_name_index]
          year = academic_year.range

          total_num_students_in_adv_courses = items[headers["# Grade 11 and 12 Students"]].to_f
          num_students_completing_adv_courses = items[headers["% Students Completing Advanced"]].to_f

          return "NA" unless white_students_in_advanced_courses[[school_id, year]]
          num_non_white_students_in_adv_courses = total_num_students_in_adv_courses - white_students_in_advanced_courses[[school_id, year]]

          return "NA" unless white_students_completing_advanced_courses[[school_id, year]]
          num_non_white_students_completing_adv_courses = num_students_completing_adv_courses - white_students_completing_advanced_courses[[school_id, year]]

          percentage_non_white_completing_adv_courses = num_non_white_students_completing_adv_courses / num_non_white_students_in_adv_courses * 100

          benchmark = 67.2
          percentage_non_white_completing_adv_courses * 4 / benchmark
        }
        admin_data_item_id = "a-curv-i7"
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

  end
end
