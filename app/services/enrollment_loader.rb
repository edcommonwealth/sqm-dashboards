# frozen_string_literal: true

require "csv"

class EnrollmentLoader
  def self.load_data(filepath:)
    enrollments = []
    CSV.parse(File.read(filepath), headers: true) do |row|
      row = EnrollmentRowValues.new(row:)
      next unless row.school.present? && row.academic_years.size.positive?

      enrollments << create_enrollment_entry(row:)
    end

    Respondent.import enrollments.flatten, batch_size: 1000,
                                           on_duplicate_key_update: %i[pk k one two three four five six seven eight nine ten eleven twelve total_students]
  end

  def self.clone_previous_year_data
    respondents = []
    School.all.each do |school|
      academic_years_without_data(school:).each do |academic_year|
        respondent = Respondent.where(school:, academic_year: last_academic_year_with_data(school:)).first
        next if respondent.nil?

        current_respondent = Respondent.find_or_initialize_by(school:, academic_year:)
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
        current_respondent.total_students = respondent.total_students
        respondents << current_respondent
      end
    end

    Respondent.import respondents,
                      batch_size: 1000, on_duplicate_key_ignore: true
  end

  private

  def self.create_enrollment_entry(row:)
    row.academic_years.map do |academic_year|
      respondent = Respondent.find_or_initialize_by(school: row.school, academic_year:)
      respondent.pk = row.pk
      respondent.k = row.k
      respondent.one = row.one
      respondent.two = row.two
      respondent.three = row.three
      respondent.four = row.four
      respondent.five = row.five
      respondent.six = row.six
      respondent.seven = row.seven
      respondent.eight = row.eight
      respondent.nine = row.nine
      respondent.ten = row.ten
      respondent.eleven = row.eleven
      respondent.twelve = row.twelve
      respondent.total_students = row.total_students
      respondent
    end
  end

  def self.last_academic_year_with_data(school:)
    AcademicYear.all.order(range: :DESC).find do |academic_year|
      Respondent.where(school:, academic_year:).any? do |respondent|
        respondent.total_students.positive?
      end
    end
  end

  def self.academic_years_without_data(school:)
    AcademicYear.all.order(range: :DESC).reject do |academic_year|
      Respondent.where(school:, academic_year:).any? do |respondent|
        respondent.total_students.positive?
      end
    end
  end

  private_class_method :create_enrollment_entry
  private_class_method :last_academic_year_with_data
  private_class_method :academic_years_without_data
end

class EnrollmentRowValues
  attr_reader :row

  def initialize(row:)
    @row = row
  end

  def school
    @school ||= begin
      dese_id = row["DESE ID"].try(:strip).to_i
      School.find_by_dese_id(dese_id)
    end
  end

  def academic_years
    @academic_years ||= begin
      year = row["Academic Year"]
      AcademicYear.of_year(year)
    end
  end

  def pk
    row["PK"] || row["pk"]
  end

  def k
    row["K"] || row["k"]
  end

  def one
    row["1"]
  end

  def two
    row["2"]
  end

  def three
    row["3"]
  end

  def four
    row["4"]
  end

  def five
    row["5"]
  end

  def six
    row["6"]
  end

  def seven
    row["7"]
  end

  def eight
    row["8"]
  end

  def nine
    row["9"]
  end

  def ten
    row["10"]
  end

  def eleven
    row["11"]
  end

  def twelve
    row["12"]
  end

  def total_students
    row["Total"].delete(",").to_i
  end
end
