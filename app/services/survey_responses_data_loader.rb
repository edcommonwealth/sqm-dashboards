# frozen_string_literal: true

class SurveyResponsesDataLoader
  def self.load_data(filepath:, rules: [Rule::NoRule])
    File.open(filepath) do |file|
      headers = file.first
      genders_hash = genders
      all_survey_items = survey_items(headers:)

      file.lazy.each_slice(500) do |lines|
        survey_item_responses = CSV.parse(lines.join, headers:).map do |row|
          process_row(row: SurveyItemValues.new(row:, headers:, genders: genders_hash, survey_items: all_survey_items),
                      rules:)
        end
        SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 500
      end
    end
  end

  def self.from_file(file:, rules: [])
    headers = file.gets
    genders_hash = genders
    all_survey_items = survey_items(headers:)

    survey_item_responses = []
    row_count = 0
    until file.eof?
      line = file.gets
      next unless line.present?

      CSV.parse(line, headers:).map do |row|
        survey_item_responses << process_row(row: SurveyItemValues.new(row:, headers:, genders: genders_hash, survey_items: all_survey_items),
                                             rules:)
      end

      row_count += 1
      next unless row_count == 1000

      SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 1000
      survey_item_responses = []
      row_count = 0
    end

    SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 1000
  end

  private

  def self.process_row(row:, rules:)
    return unless row.dese_id?
    return unless row.school.present?

    rules.each do |rule|
      return if rule.new(row:).skip_row?
    end

    process_survey_items(row:)
  end

  def self.process_survey_items(row:)
    row.survey_items.map do |survey_item|
      likert_score = row.likert_score(survey_item_id: survey_item.survey_item_id) || next

      unless likert_score.valid_likert_score?
        puts "Response ID: #{row.response_id}, Likert score: #{likert_score} rejected" unless likert_score == 'NA'
        next
      end
      response = row.survey_item_response(survey_item:)
      create_or_update_response(survey_item_response: response, likert_score:, row:, survey_item:)
    end.compact
  end

  def self.create_or_update_response(survey_item_response:, likert_score:, row:, survey_item:)
    gender = row.gender
    grade = row.grade
    if survey_item_response.present?
      survey_item_response.update!(likert_score:, grade:, gender:)
      []
    else
      SurveyItemResponse.new(response_id: row.response_id, academic_year: row.academic_year, school: row.school, survey_item:,
                             likert_score:, grade:, gender:)
    end
  end

  def self.genders
    gender_hash = {}

    Gender.all.each do |gender|
      gender_hash[gender.qualtrics_code] = gender
    end
    gender_hash
  end

  def self.survey_items(headers:)
    SurveyItem.where(survey_item_id: get_survey_item_ids_from_headers(headers:))
  end

  def self.get_survey_item_ids_from_headers(headers:)
    CSV.parse(headers, headers: true).headers
       .filter(&:present?)
       .filter { |header| header.start_with? 't-' or header.start_with? 's-' }
  end

  private_class_method :process_row
  private_class_method :process_survey_items
  private_class_method :create_or_update_response
  private_class_method :genders
  private_class_method :survey_items
  private_class_method :get_survey_item_ids_from_headers
end

module StringMonkeyPatches
  def valid_likert_score?
    to_i.between? 1, 5
  end
end

String.include StringMonkeyPatches
