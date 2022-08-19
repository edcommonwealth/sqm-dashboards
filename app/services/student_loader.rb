# frozen_string_literal: true

# SurveyItemResponse.where(student: StudentRace.where(race: Race.find_by_qualtrics_code(8)).limit(10).map(&:student)).count

# TODO: figure out why earlier years don't have races attached
require 'csv'

class StudentLoader
  def self.load_data(filepath:, reinitialize: false)
    destroy_students if reinitialize

    File.open(filepath) do |file|
      headers = file.first

      file.lazy.each_slice(1_000) do |lines|
        CSV.parse(lines.join, headers:).map do |row|
          process_row(row:)
        end
      end
    end
  end

  def self.destroy_students
    SurveyItemResponse.update_all(student_id: nil)
    StudentRace.delete_all
    Student.delete_all
  end

  def self.process_row(row:)
    races = process_races(codes: race_codes(row:))
    response_id = row['ResponseId'] || row['Responseid'] || row['ResponseID'] ||
                  row['Response ID'] || row['Response id'] || row['Response Id']
    lasid = row['LASID'] || row['lasid']

    find_or_create_student(response_id:, lasid:, races:)
  end

  def self.race_codes(row:)
    race_codes = row['RACE'] || row['Race'] || row['race'] || row['What is your race/ethnicity?(Please select all that apply) - Selected Choice'] || '99'
    race_codes.split(',').map(&:to_i) || []
  end

  def self.assign_student_to_responses(student:, response_id:)
    responses = SurveyItemResponse.where(response_id:)
    loadable_responses = responses.map do |response|
      response.student = student
      response
    end

    SurveyItemResponse.import(loadable_responses.flatten.compact, batch_size: 1_000, on_duplicate_key_update: :all)
  end

  def self.find_or_create_student(response_id:, lasid:, races:)
    student = Student.find_by(response_id:, lasid:)
    return unless student.nil?

    student = Student.create(response_id:, lasid:)
    races.map do |race|
      student.races << race
    end
    assign_student_to_responses(student:, response_id:)
  end

  def self.process_races(codes:)
    races = codes.map do |code|
      code = code.to_i
      code = 99 if [6, 7].include?(code) || code.nil? || code.zero?
      Race.find_by_qualtrics_code(code)
    end.uniq
    races = add_unknown_race_if_other_races_missing(races:)
    races = remove_unknown_race_if_other_races_present(races:)
    add_multiracial_designation(races:)
  end

  def self.remove_unknown_race_if_other_races_present(races:)
    races.delete(Race.find_by_qualtrics_code(99)) if races.length > 1
    races
  end

  def self.add_multiracial_designation(races:)
    races << Race.find_by_qualtrics_code(100) if races.length > 1
    races
  end

  def self.add_unknown_race_if_other_races_missing(races:)
    races << Race.find_by_qualtrics_code(99) if races.length == 0
    races
  end
end
