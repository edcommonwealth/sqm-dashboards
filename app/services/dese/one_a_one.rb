require 'watir'
require 'csv'
# TODO: convert this to simpler format  and add a run_all method
module Dese
  class OneAOne
    attr_reader :filepath

    def initialize(filepath: Rails.root.join('data', 'admin_data', 'dese', '1A_1_teacher_data.csv'))
      @filepath = filepath
    end

    def run_all
      url = 'https://profiles.doe.mass.edu/statereport/teacherdata.aspx'
      browser = Watir::Browser.new
      write_headers(filepath:)
      academic_years = AcademicYear.all
      academic_years.each do |academic_year|
        document = scrape(browser:, url:, range: academic_year.range)
        id = 'a-exp-i1'
        write_csv(document:, filepath:, range: academic_year.range, id:) unless document.nil?
      end
      browser.close
    end

    def scrape(browser:, url:, range:)
      browser.goto(url)

      return unless browser.option(text: 'School').present?
      return unless browser.option(text: range).present?

      browser.select(id: 'ctl00_ContentPlaceHolder1_ddReportType').select(text: 'School')
      browser.select(id: 'ctl00_ContentPlaceHolder1_ddYear').select(text: range)
      browser.button(id: 'ctl00_ContentPlaceHolder1_btnViewReport').click
      sleep Dese::Scraper::DELAY  # Sleep to prevent hitting mass.edu with too many requests
      Nokogiri::HTML(browser.html)
    end

    def write_headers(filepath:)
      CSV.open(filepath, 'w') do |csv|
        headers = ['Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year', 'School Name', 'DESE ID', 'Total # of Teachers(FTE)', 'Percent of Teachers Licensed',
                   'Student/Teacher Ratio', 'Percent of Experienced Teachers', 'Percent of Teachers without Waiver or Provisional License', 'Percent Teaching in-field']
        csv << headers
      end
    end

    def write_csv(document:, filepath:, range:, id:)
      table = document.css('tr')
      headers = document.css('.sorting')
      header_hash = headers.each_with_index.map { |header, index| [header.text, index] }.to_h
      experienced_teacher_index = header_hash['Percent of Experienced Teachers']
      dese_id_index = header_hash['School Code']

      CSV.open(filepath, 'a') do |csv|
        table.each do |row|
          items = row.css('td').map(&:text)
          dese_id = items[1].to_i
          next if dese_id.nil? || dese_id.zero?

          raw_likert_score = items[experienced_teacher_index].to_f * 4 / 80 if experienced_teacher_index.present?
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
          output << 'a-exp-i1'
          output << range
          output << items
          output = output.flatten
          csv << output
        end
      end

      in_field_index = header_hash['Percent Teaching In-Field']

      CSV.open(filepath, 'a') do |csv|
        table.each do |row|
          items = row.css('td').map(&:text)
          dese_id = items[dese_id_index].to_i
          next if dese_id.nil? || dese_id.zero?

          percent_in_field = items[in_field_index].to_f if in_field_index.present?
          if in_field_index.present? && percent_in_field.present? && !percent_in_field.zero?
            raw_likert_score = percent_in_field * 4 / 95
          end
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
          output << 'a-exp-i3'
          output << range
          output << items
          output = output.flatten
          csv << output
        end
      end
    end

    def calculate(cells:)
      cells[5].to_f * 4 / 95
    end
  end
end
