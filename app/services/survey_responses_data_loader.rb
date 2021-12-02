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
        survey_item_responses = CSV.parse(lines.join, headers: headers).map do |row|
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

    response_id = row['Response ID'] || row['ResponseId']

    district_code = row['District'] || row['district']
    school_code = row['School'] || row['school']
    return if school_code.nil?

    school = School.find_by_district_code_and_school_code(district_code, school_code)
    return if school.nil?

    survey_items.map do |survey_item|
      next if SurveyItemResponse.where(response_id: response_id, survey_item: survey_item).exists?

      likert_score = row[survey_item.survey_item_id]
      next if likert_score.nil?
      next unless likert_score.valid_likert_score?

      SurveyItemResponse.new(
        response_id: response_id,
        academic_year: academic_year,
        school: school,
        survey_item: survey_item,
        likert_score: likert_score
      )
    end.compact
  end

  private_class_method :process_row
end

module StringMonkeyPatches
  def integer?
    self.to_i.to_s == self
  end

  def valid_likert_score?
    self.integer? and self.to_i.between? 1, 5
  end
end

String.include StringMonkeyPatches
