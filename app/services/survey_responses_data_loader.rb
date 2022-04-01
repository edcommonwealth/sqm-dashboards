require 'csv'

class SurveyResponsesDataLoader
  def self.load_data(filepath:)
    File.open(filepath) do |file|
      headers = file.first

      survey_item_ids = CSV.parse(headers, headers: true).headers
                           .filter { |header| header.present? }
                           .filter { |header| header.start_with? 't-' or header.start_with? 's-' }
      survey_items = SurveyItem.where(survey_item_id: survey_item_ids)

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
    response_date = Date.parse(row['Recorded Date'] || row['RecordedDate'])
    academic_year = AcademicYear.find_by_date response_date

    response_id = row['Response ID'] || row['ResponseId'] || row['ResponseID']

    dese_id = row['DESE ID']
    return if dese_id.nil?

    school = School.find_by_dese_id(dese_id)
    return if school.nil?

    survey_items.map do |survey_item|
      likert_score = row[survey_item.survey_item_id]
      next if likert_score.nil?
      next unless likert_score.valid_likert_score?

      survey_item_response = SurveyItemResponse.where(response_id:, survey_item:).first
      if survey_item_response.present?
        survey_item_response.update!(likert_score:) if survey_item_response.likert_score != likert_score
        next
      else
        SurveyItemResponse.new(
          response_id:,
          academic_year:,
          school:,
          survey_item:,
          likert_score:
        )
      end
    end.compact
  end

  private_class_method :process_row
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
