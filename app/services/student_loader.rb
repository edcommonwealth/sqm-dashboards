# frozen_string_literal: true

class StudentLoader
  def self.load_data(filepath:, rules: [])
    File.open(filepath) do |file|
      headers = file.first
      headers_array = headers.split(",")

      file.lazy.each_slice(1_000) do |lines|
        CSV.parse(lines.join, headers:).map do |row|
          row = SurveyItemValues.new(row:, headers: headers_array, genders: nil, survey_items: nil, schools:)
          next if rules.any? do |rule|
                    rule.new(row:).skip_row?
                  end

          process_row(row:)
        end
      end
    end
  end

  def self.from_file(file:, rules: [])
    headers = file.gets
    headers_array = headers.split(",")

    until file.eof?
      line = file.gets
      next unless line.present?

      CSV.parse(line, headers:).map do |row|
        row = SurveyItemValues.new(row:, headers: headers_array, genders: nil, survey_items: nil, schools:)
        next if rules.any? do |rule|
                  rule.new(row:).skip_row?
                end

        process_row(row:)
      end
    end
  end

  def self.process_row(row:)
    student = Student.find_or_create_by(response_id: row.response_id, lasid: row.lasid)
    student.races.delete_all
    races = row.races
    races.map do |race|
      student.races << race
    end
    assign_student_to_responses(student:, response_id: row.response_id)
  end

  def self.schools
    @schools ||= School.all.map { |school| [school.dese_id, school] }.to_h
  end

  def self.assign_student_to_responses(student:, response_id:)
    responses = SurveyItemResponse.where(response_id:)
    loadable_responses = responses.map do |response|
      response.student = student
      response
    end

    SurveyItemResponse.import(loadable_responses.flatten.compact, batch_size: 1_000, on_duplicate_key_update: :all)
  end
end
