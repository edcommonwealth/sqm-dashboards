# frozen_string_literal: true

require 'csv'

class SurveyResponsesDataLoader
  def self.load_data(filepath:, rules: [Rule::NoRule])
    File.open(filepath) do |file|
      headers = file.first
      genders_hash = genders
      all_survey_items = survey_items(headers:)

      file.lazy.each_slice(500) do |lines|
        survey_item_responses = CSV.parse(lines.join, headers:).map do |row|
          process_row(row: Values.new(row:, headers:, genders: genders_hash, survey_items: all_survey_items),
                      rules:)
        end

        SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 500
      end
    end
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

class Values
  attr_reader :row, :headers, :genders, :survey_items

  def initialize(row:, headers:, genders:, survey_items:)
    @row = row
    @headers = headers
    @genders = genders
    @survey_items = survey_items
  end

  def dese_id?
    dese_id.present?
  end

  def response_date
    @response_date ||= Date.parse(row['Recorded Date'] || row['RecordedDate'])
  end

  def academic_year
    @academic_year ||= AcademicYear.find_by_date response_date
  end

  def survey_item_response(survey_item:)
    @survey_item_response ||= Hash.new do |memo, survey_item|
      memo[survey_item] = survey_item_responses[[response_id, survey_item.id]]
    end

    @survey_item_response[survey_item]
  end

  def survey_item_responses
    @survey_item_responses ||= Hash.new do |memo|
      responses_hash = {}
      SurveyItemResponse.where(school:, academic_year:, response_id:).each do |response|
        responses_hash[[response.response_id, response.survey_item.id]] = response
      end
      memo[[school, academic_year]] = responses_hash
    end

    @survey_item_responses[[school, academic_year]]
  end

  def response_id
    @response_id ||= row['Response ID'] || row['ResponseId'] || row['ResponseID']
  end

  def dese_id
    @dese_id ||= (row['DESE ID' || 'Dese ID'] || row['DeseId'] || row['DeseID'] || row['School'] || row['school']).to_i
  end

  def likert_score(survey_item_id:)
    row[survey_item_id]
  end

  def school
    @school ||= School.find_by_dese_id(dese_id)
  end

  def grade
    @grade ||= begin
      raw_grade = (row['grade'] || row['Grade'] || row['What grade are you in?']).to_i
      raw_grade == 0 ? nil : raw_grade
    end
  end

  def gender
    gender_code = row['gender'] || row['Gender'] || 99
    gender_code = gender_code.to_i
    gender_code = 4 if gender_code == 3
    gender_code = 99 if gender_code.zero?
    genders[gender_code]
  end
end

module StringMonkeyPatches
  def valid_likert_score?
    to_i.between? 1, 5
  end
end

String.include StringMonkeyPatches
