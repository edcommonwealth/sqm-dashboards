require 'csv'

class SurveyResponsesDataLoader
  def self.load_data(filepath:)
    File.open(filepath) do |file|
      headers = file.first
      survey_items = SurveyItem.where(survey_item_id: get_survey_item_ids_from_headers(file:, headers:))

      file.lazy.each_slice(1000) do |lines|
        survey_item_responses = CSV.parse(lines.join, headers:).map do |row|
          process_row row: row, survey_items: survey_items
        end

        SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 1000
      end
    end
  end

  private

  def self.process_row(row:, survey_items:)
    return unless dese_id?(row['DESE ID'])

    school = School.find_by_dese_id(row['DESE ID'])
    return unless school.present?

    process_survey_items(row:, survey_items:, school:)
  end

  def self.process_survey_items(row:, survey_items:, school:)
    response_id = row['Response ID'] || row['ResponseId'] || row['ResponseID']
    survey_items.map do |survey_item|
      likert_score = row[survey_item.survey_item_id]
      next if likert_score.nil?

      unless likert_score.valid_likert_score?
        puts "Response ID: #{response_id}, Likert score: #{likert_score} rejected" unless likert_score == 'NA'
        next
      end

      survey_item_response = SurveyItemResponse.where(response_id:, survey_item:).first
      create_or_update_survey_item_response(survey_item_response:, likert_score:, school:, response_id:, row:,
                                            survey_item:)
    end.compact
  end

  def self.create_or_update_survey_item_response(survey_item_response:, likert_score:, school:, row:, survey_item:, response_id:)
    if survey_item_response.present?
      survey_item_response.update!(likert_score:) if survey_item_response.likert_score != likert_score
      []
    else
      SurveyItemResponse.new(response_id:, academic_year: academic_year(row), school:, survey_item:, likert_score:)
    end
  end

  def self.get_survey_item_ids_from_headers(file:, headers:)
    CSV.parse(headers, headers: true).headers
       .filter { |header| header.present? }
       .filter { |header| header.start_with? 't-' or header.start_with? 's-' }
  end

  def self.dese_id?(dese_id)
    dese_id.present?
  end

  def self.response_date(row)
    Date.parse(row['Recorded Date'] || row['RecordedDate'])
  end

  def self.academic_year(row)
    AcademicYear.find_by_date response_date(row)
  end

  private_class_method :process_row
  private_class_method :process_survey_items
  private_class_method :get_survey_item_ids_from_headers
  private_class_method :dese_id?
end

module StringMonkeyPatches
  def integer?
    to_i.to_s == self
  end

  def valid_likert_score?
    integer? and to_i.between? 1, 5
  end
end

String.include StringMonkeyPatches
