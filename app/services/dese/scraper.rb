module Dese
  module Scraper
    DELAY = 20 # The dese site will block you if you hit it too many times in a short period of time

    Prerequisites = Struct.new("Prerequisites", :filepath, :url, :selectors, :submit_id, :admin_data_item_id,
                               :calculation)
    def run
      academic_years = AcademicYear.all.order(range: :DESC)
                                   .map(&:range_without_season)
                                   .uniq
                                   .map { |range| AcademicYear.new(range:) }
      academic_years.each do |academic_year|
        prerequisites = yield academic_year

        document = get_html(url: prerequisites.url,
                            selectors: prerequisites.selectors,
                            submit_id: prerequisites.submit_id)
        unless document.nil?
          write_csv(document:, filepath: prerequisites.filepath, range: academic_year.range_without_season, id: prerequisites.admin_data_item_id,
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
      sleep DELAY # Sleep to prevent hitting mass.edu with too many requests
      Nokogiri::HTML(browser.html)
    end

    def write_headers(filepath:, headers:)
      CSV.open(filepath, "w") do |csv|
        csv << headers
      end
    end

    def write_csv(document:, filepath:, range:, id:, calculation:)
      table = document.css("tr")
      headers = document.css(".sorting")
      header_hash = headers.each_with_index.map { |header, index| [header.text, index] }.to_h

      CSV.open(filepath, "a") do |csv|
        table.each do |row|
          items = row.css("td").map(&:text)
          dese_id = items[1].to_i
          next if dese_id.nil? || dese_id.zero?

          # row = header_hash.keys.zip(items).to_h

          raw_likert_score = calculation.call(header_hash, items)
          raw_likert_score ||= "NA"
          likert_score = raw_likert_score
          if likert_score != "NA"
            likert_score = 5 if likert_score > 5
            likert_score = 1 if likert_score < 1
            likert_score = likert_score.round(2)
          end

          # school_level = row["School Code"][-3]
          # ratio = row["Number of Students"].gsub(",", "").to_f / row["Total # of Classes"].gsub(",", "").to_f

          output = []
          output << raw_likert_score
          output << likert_score
          output << id
          output << range
          output << items
          # output << school_level
          # output << ratio
          output = output.flatten
          csv << output
        end
      end
    end

    def is_hs?(school_id:, school_name:)
      school_id = school_id.to_s
      school_id[-3] == "5" || school_name =~ /\sHigh$|\sHigh\s/i
    end
  end
end
