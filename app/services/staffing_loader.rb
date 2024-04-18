# frozen_string_literal: true

require "csv"

class StaffingLoader
  def self.load_data(filepath:)
    respondents = []
    CSV.parse(File.read(filepath), headers: true) do |row|
      row = StaffingRowValues.new(row:)
      next unless row.school.present? && row.academic_years.size.positive?

      respondents.concat(create_staffing_entry(row:))
    end

    Respondent.import respondents, batch_size: 1000, on_duplicate_key_update: [:total_teachers]
  end

  def self.clone_previous_year_data
    respondents = []
    School.all.each do |school|
      academic_years_without_data(school:).each do |academic_year|
        year_with_data = last_academic_year_with_data(school:)
        respondent = Respondent.where(school:, academic_year: year_with_data).first
        next if respondent.nil?

        current_respondent = Respondent.find_or_initialize_by(school:, academic_year:)
        if current_respondent.total_teachers.nil? || current_respondent.total_teachers.zero?
          current_respondent.total_teachers = respondent.total_teachers
        end
        respondents << current_respondent
      end
    end
    Respondent.import respondents, batch_size: 1000, on_duplicate_key_update: [:total_teachers]
  end

  private

  def self.create_staffing_entry(row:)
    row.academic_years.map do |academic_year|
      respondent = Respondent.find_or_initialize_by(school: row.school, academic_year:)
      respondent.total_teachers = row.fte_count
      respondent
    end
  end

  def self.last_academic_year_with_data(school:)
    AcademicYear.all.order(range: :DESC).find do |academic_year|
      respondents = Respondent.find_by(school:, academic_year:)
      respondents&.total_teachers&.positive?
    end
  end

  def self.academic_years_without_data(school:)
    AcademicYear.all.order(range: :DESC).select do |academic_year|
      respondents = Respondent.find_by(school:, academic_year:)
      respondents.nil? || respondents.total_teachers.nil? || respondents.total_teachers.zero?
    end
  end

  private_class_method :last_academic_year_with_data
  private_class_method :academic_years_without_data
  private_class_method :create_staffing_entry
end

class StaffingRowValues
  attr_reader :row

  def initialize(row:)
    @row = row
  end

  def school
    @school ||= begin
      dese_id = row["DESE ID"].strip.to_i
      School.find_by_dese_id(dese_id)
    end
  end

  def academic_years
    @academic_year ||= begin
      year = row["Academic Year"]
      AcademicYear.of_year(year)
    end
  end

  def fte_count
    row["FTE Count"]
  end
end
