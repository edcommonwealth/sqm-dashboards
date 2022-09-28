# frozen_string_literal: true

require 'csv'

class SurveyResponsesDataLoader
  def self.load_data(filepath:)
    File.open(filepath) do |file|
      headers = file.first

      file.lazy.each_slice(1000) do |lines|
        survey_item_responses = CSV.parse(lines.join, headers:).map do |row|
          process_row row: Values.new(row:, headers:)
        end

        SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 1000
      end
    end
  end

  private

  def self.process_row(row:)
    return unless row.dese_id?
    return unless row.school.present?

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
    if survey_item_response.present?
      survey_item_response.update!(likert_score:)
      []
    else
      SurveyItemResponse.new(response_id: row.response_id, academic_year: row.academic_year, school: row.school, survey_item:,
                             likert_score:, grade: row.grade)
    end
  end

  private_class_method :process_row
  private_class_method :process_survey_items
  private_class_method :create_or_update_response
end

class Values
  attr_reader :row, :headers

  def initialize(row:, headers:)
    @row = row
    @headers = headers
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
    SurveyItemResponse.find_by(response_id:, survey_item:)
  end

  def response_id
    @response_id ||= row['Response ID'] || row['ResponseId'] || row['ResponseID']
  end

  def dese_id
    @dese_id ||= (row['DESE ID' || 'Dese ID'] || row['DeseId'] || row['DeseID']).to_i
  end

  def likert_score(survey_item_id:)
    row[survey_item_id]
  end

  def school
    @school ||= School.find_by_dese_id(dese_id)
  end

  def survey_items
    @survey_items ||= SurveyItem.where(survey_item_id: get_survey_item_ids_from_headers(headers:))
  end

  def get_survey_item_ids_from_headers(headers:)
    CSV.parse(headers, headers: true).headers
       .filter(&:present?)
       .filter { |header| header.start_with? 't-' or header.start_with? 's-' }
  end

  def grade
    @grade ||= begin
      raw_grade = (row['grade'] || row['Grade'] || row['What grade are you in?']).to_i
      raw_grade == 0 ? nil : raw_grade
    end
  end
end

module StringMonkeyPatches
  def valid_likert_score?
    to_i.between? 1, 5
  end
end

String.include StringMonkeyPatches
