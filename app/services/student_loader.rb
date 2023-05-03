# frozen_string_literal: true

require 'csv'

class StudentLoader
  def self.load_data(filepath:, rules: [])
    File.open(filepath) do |file|
      headers = file.first

      file.lazy.each_slice(1_000) do |lines|
        CSV.parse(lines.join, headers:).map do |row|
          next if rules.any? do |rule|
                    rule.new(row: SurveyItemValues.new(row:, headers:, genders: nil, survey_items: nil,
                                                       schools:)).skip_row?
                  end

          process_row(row:)
        end
      end
    end
  end

  def self.from_file(file:, rules: [])
    headers = file.gets

    survey_item_responses = []
    until file.eof?
      line = file.gets
      next unless line.present?

      CSV.parse(line, headers:).map do |row|
        next if rules.any? do |rule|
                  rule.new(row: SurveyItemValues.new(row:, headers:, genders: nil, survey_items: nil,
                                                     schools:)).skip_row?
                end

        process_row(row:)
      end

    end
  end

  def self.process_row(row:)
    races = process_races(codes: race_codes(row:))
    response_id = row['ResponseId'] || row['Responseid'] || row['ResponseID'] ||
                  row['Response ID'] || row['Response id'] || row['Response Id']
    lasid = row['LASID'] || row['lasid']

    find_or_create_student(response_id:, lasid:, races:)
  end

  def self.schools
    @schools ||= School.all.map { |school| [school.dese_id, school] }.to_h
  end

  def self.race_codes(row:)
    race_codes = row['race'] || row['RACE'] || row['Race'] || '99'
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
    student = Student.find_or_create_by(response_id:, lasid:)
    student.races.delete_all
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
