require "csv"

class EspLoader
  def self.load_data(filepath:)
    respondents = []
    CSV.parse(File.read(filepath), headers: true) do |row|
      row = EspRowValues.new(row:)
      next unless row.school.present? && row.academic_years.size.positive?

      respondents.concat(create_esp_entry(row:))
    end

    Respondent.import respondents, batch_size: 1000, on_duplicate_key_update: [:total_esp]
  end

  def self.create_esp_entry(row:)
    row.academic_years.map do |academic_year|
      respondent = Respondent.find_or_initialize_by(school: row.school, academic_year:)
      respondent.total_esp = row.total_esp
      respondent
    end
  end
end

class EspRowValues
  attr_reader :row

  def initialize(row:)
    @row = row
  end

  def school
    @school ||= begin
      dese_id = row["DESE ID"]&.strip.to_i
      School.find_by_dese_id(dese_id)
    end
  end

  def academic_years
    @academic_year ||= begin
      year = row["Academic Year"]&.strip
      AcademicYear.of_year(year)
    end
  end

  def total_esp
    row["School Totals"]&.strip&.gsub(",", "").to_i
  end
end
