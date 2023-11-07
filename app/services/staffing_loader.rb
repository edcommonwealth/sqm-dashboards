# frozen_string_literal: true

require "csv"

class StaffingLoader
  def self.load_data(filepath:)
    schools = []
    respondents = []
    CSV.parse(File.read(filepath), headers: true) do |row|
      row = StaffingRowValues.new(row:)
      next unless row.school.present? && row.academic_year.present?

      schools << row.school

      respondents << create_staffing_entry(row:)
    end

    Respondent.import respondents, batch_size: 1000, on_duplicate_key_update: [:total_teachers]
    Respondent.where.not(school: schools).destroy_all
  end

  def self.clone_previous_year_data
    years = AcademicYear.order(:range).last(2)
    previous_year = years.first
    current_year = years.last
    respondents = []
    School.all.each do |school|
      Respondent.where(school:, academic_year: previous_year).each do |respondent|
        current_respondent = Respondent.find_or_initialize_by(school:, academic_year: current_year)
        current_respondent.total_teachers = respondent.total_teachers
        current_respondent.pk = respondent.pk
        current_respondent.k = respondent.k
        current_respondent.one = respondent.one
        current_respondent.two = respondent.two
        current_respondent.three = respondent.three
        current_respondent.four = respondent.four
        current_respondent.five = respondent.five
        current_respondent.six = respondent.six
        current_respondent.seven = respondent.seven
        current_respondent.eight = respondent.eight
        current_respondent.nine = respondent.nine
        current_respondent.ten = respondent.ten
        current_respondent.eleven = respondent.eleven
        current_respondent.twelve = respondent.twelve

        respondents << current_respondent
      end
    end
    Respondent.import respondents, batch_size: 1000, on_duplicate_key_update: [:total_teachers]
  end

  private

  def self.create_staffing_entry(row:)
    respondent = Respondent.find_or_initialize_by(school: row.school, academic_year: row.academic_year)
    respondent.total_teachers = row.fte_count
    respondent
  end

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

  def academic_year
    @academic_year ||= begin
      year = row["Academic Year"]
      AcademicYear.find_by_range(year)
    end
  end

  def fte_count
    row["FTE Count"]
  end
end
