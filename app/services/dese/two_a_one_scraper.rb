require 'watir'
require 'csv'

module Dese
  class TwoAOneScraper
    attr_reader :filepaths

    Prerequisites = Struct.new('Prerequisites', :filepath, :url, :selectors, :submit_id, :admin_data_item_id,
                               :calculation)

    def initialize(filepaths: [Rails.root.join('data', 'admin_data', 'dese', 'two_a_one_students_suspended.csv'),
                               Rails.root.join('data', 'admin_data', 'dese', 'two_a_one_students_disciplined.csv')])
      @filepaths = filepaths

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
          suspensions = headers['% Out-of-School Suspension']
          result = items[suspensions].to_f * 4 / 5.27 if suspensions.present?

          reverse_score(likert_score: result)
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
          days_missed = headers['% > 10 Days']
          result = items[days_missed].to_f * 4 if days_missed.present?

          reverse_score(likert_score: result)
        }
        admin_data_item_id = 'a-phys-i3'
        Prerequisites.new(filepath, url, selectors, submit_id, admin_data_item_id, calculation)
      end
    end

    def reverse_score(likert_score:)
      return nil unless likert_score.present?

      likert_score = 1 if likert_score < 1
      likert_score = 5 if likert_score > 5
      (likert_score - 6).abs
    end

    def run
      academic_years = AcademicYear.all.order(range: :DESC)
      academic_years.each do |academic_year|
        prerequisites = yield academic_year

        document = get_html(url: prerequisites.url,
                            selectors: prerequisites.selectors,
                            submit_id: prerequisites.submit_id)
        unless document.nil?
          write_csv(document:, filepath: prerequisites.filepath, range: academic_year.range, id: prerequisites.admin_data_item_id,
                    calculation: prerequisites.calculation)
        end
      end
    end

    def browser
      @browser ||= Watir::Browser.new
    end

    def get_html(url:, selectors:, submit_id:)
      browser.goto(url)

      selectors.each do |key, value|
        return unless browser.option(text: value).present?

        browser.select(id: key).select(text: value)
      end

      browser.button(id: submit_id).click
      sleep 2 # Sleep to prevent hitting mass.edu with too many requests
      Nokogiri::HTML(browser.html)
    end

    def write_headers(filepath:, headers:)
      CSV.open(filepath, 'w') do |csv|
        csv << headers
      end
    end

    def write_csv(document:, filepath:, range:, id:, calculation:)
      table = document.css('tr')
      headers = document.css('.sorting')
      header_hash = headers.each_with_index.map { |header, index| [header.text, index] }.to_h

      CSV.open(filepath, 'a') do |csv|
        table.each do |row|
          items = row.css('td').map(&:text)
          dese_id = items[1].to_i
          next if dese_id.nil? || dese_id.zero?

          raw_likert_score = calculation.call(header_hash, items)
          raw_likert_score ||= 'NA'
          likert_score = raw_likert_score
          if likert_score != 'NA'
            likert_score = 5 if likert_score > 5
            likert_score = 1 if likert_score < 1
            likert_score = likert_score.round(2)
          end

          output = []
          output << raw_likert_score
          output << likert_score
          output << id
          output << range
          output << items
          output = output.flatten
          csv << output
        end
      end
    end
  end
end
