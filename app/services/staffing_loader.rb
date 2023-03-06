# frozen_string_literal: true

require 'csv'

class StaffingLoader
  def self.load_data(filepath:)
    schools = []
    CSV.parse(File.read(filepath), headers: true) do |row|
      row = StaffingRowValues.new(row:)
      next unless row.school.present? && row.academic_year.present?

      schools << row.school

      create_staffing_entry(row:)
    end

    Respondent.where.not(school: schools).destroy_all
  end

  def self.clone_previous_year_data
    years = AcademicYear.order(:range).last(2)
    previous_year = years.first
    current_year = years.last
    School.all.each do |school|
      Respondent.where(school:, academic_year: previous_year).each do |respondent|
        current_respondent = Respondent.find_or_initialize_by(school:, academic_year: current_year)
        current_respondent.total_teachers = respondent.total_teachers
        current_respondent.save
      end
    end
  end

  private

  def self.create_staffing_entry(row:)
    respondent = Respondent.find_or_initialize_by(school: row.school, academic_year: row.academic_year)
    respondent.total_teachers = row.fte_count
    respondent.save
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
      dese_id = row['DESE ID'].strip.to_i
      School.find_by_dese_id(dese_id)
    end
  end

  def academic_year
    @academic_year ||= begin
      year = row['Academic Year']
      AcademicYear.find_by_range(year)
    end
  end

  def fte_count
    row['FTE Count']
  end
end
