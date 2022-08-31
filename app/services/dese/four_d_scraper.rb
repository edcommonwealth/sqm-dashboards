require 'watir'
require 'csv'

module Dese
  class FourDScraper
    def initialize(filepath: Rails.root.join('data', 'admin_data', 'dese', 'four_d.csv'))
      url = 'https://profiles.doe.mass.edu/statereport/plansofhsgrads.aspx'
      browser = Watir::Browser.new
      write_headers(filepath:)
      academic_years = AcademicYear.all
      academic_years.each do |academic_year|
        table = scrape(browser:, url:, range: academic_year.range)
        id = 'a-cgpr-i1'
        write_csv(table:, filepath:, range: academic_year.range, id:) unless table.nil?
      end
      browser.close
    end

    def scrape(browser:, url:, range:)
      browser.goto(url)

      return unless browser.option(text: range).present?

      browser.select(id: 'ctl00_ContentPlaceHolder1_ddReportType').select(/School/)
      browser.select(id: 'ctl00_ContentPlaceHolder1_ddYear').select(text: range)
      browser.button(id: 'btnViewReport').click
      sleep 5  # Sleep to prevent hitting mass.edu with too many requests
      document = Nokogiri::HTML(browser.html)
      document.css('tr')
    end

    def write_headers(filepath:)
      CSV.open(filepath, 'w') do |csv|
        headers = ['School Name', 'DESE ID', '4 Year Private College', '4 Year Public College', '2 Year Private College', '2 Year Public College',
                   'Other Post Secondary', 'Apprenticeship', 'Work', 'Military', 'Other', 'Unknown', 'Total', 'Raw likert calculation', 'Likert Score', 'Admin Data Item', 'Academic Year']
        csv << headers
      end
    end

    def write_csv(table:, filepath:, range:, id:)
      CSV.open(filepath, 'a') do |csv|
        table.each do |row|
          items = row.css('td').map(&:text)
          dese_id = items[1].to_i
          next if dese_id.nil? || dese_id.zero?

          raw_likert_score = calculate(cells: items)
          items << raw_likert_score
          likert_score = raw_likert_score
          likert_score = 5 if raw_likert_score > 5
          likert_score = 1 if raw_likert_score < 1
          likert_score = likert_score.round(2)
          items << likert_score
          items << id
          items << range
          csv << items
        end
      end
    end

    def calculate(cells:)
      (cells[2].to_f + cells[3].to_f + cells[4].to_f + cells[5].to_f + cells[6].to_f + cells[7].to_f + cells[8].to_f) * 4 / 75
    end
  end
end
