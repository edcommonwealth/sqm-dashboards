# frozen_string_literal: true

# SurveyItemResponse.where(student: StudentRace.where(race: Race.find_by_qualtrics_code(8)).limit(10).map(&:student)).count
require 'csv'

class StudentLoader
  def self.load_data(filepath:)
    File.open(filepath) do |file|
      headers = file.first

      students = []
      file.lazy.each_slice(1000) do |lines|
        CSV.parse(lines.join, headers:).map do |row|
          # students << process_row(row:)
          process_row(row:)
        end
      end
      # Student.import students.compact.flatten.to_set.to_a, batch_size: 1000,
      #                                                      on_duplicate_key_update: { conflict_target: [:id] }
    end
  end

  def self.process_row(row:)
    race_codes = row['RACE'] || row['What is your race/ethnicity?(Please select all that apply) - Selected Choice'] || '99'
    race_codes = race_codes.split(',').map(&:to_i) || []
    races = process_races(codes: race_codes)
    response_id = row['ResponseId'] || row['Responseid'] || row['ResponseID'] ||
                  row['Response ID'] || row['Response id'] || row['Response Id']
    lasid = row['LASID'] || row['lasid']
    return nil if student_exists?(response_id:)

    student = create_student(response_id:, lasid:, races:)

    assign_student_to_responses(response_id:, student:)
    student
  end

  def self.student_exists?(response_id:)
    Student.find_by_response_id(response_id).present?
  end

  def self.assign_student_to_responses(response_id:, student:)
    survey_responses = SurveyItemResponse.where(response_id:)
    survey_responses.each do |response|
      response.student = student
      response.save
    end

    # SurveyItemResponse.import survey_responses, on_duplicate_key_update: { conflict_target: [:id], columns: [:student] }
  end

  def self.create_student(response_id:, lasid:, races:)
    student = Student.new(response_id:)
    races.each do |race|
      student.races << race
    end
    student.lasid = lasid
    student.save
    student
  end

  def self.process_races(codes:)
    codes = codes.map do |code|
      code = 99 if [6, 7].include?(code)
      Race.find_by_qualtrics_code(code)
    end
    remove_unknown_race_if_other_races_present(races: codes.to_set)
  end

  def self.remove_unknown_race_if_other_races_present(races:)
    races.delete(Race.find_by_qualtrics_code(99)) if races.length > 1
    races
  end
end
