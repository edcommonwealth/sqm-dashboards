require 'csv'

class SurveyResponsesDataLoader

  def self.load_data(filepath:)
    csv_file = File.read(filepath)

    parsed_csv_file = CSV.parse(csv_file, headers: true)
    survey_items = parsed_csv_file.headers
                         .filter { |header| !header.nil? }
                         .filter { |header| header.start_with? 't-' or header.start_with? 's-' }
                         .map { |survey_item_id| SurveyItem.find_by_survey_item_id survey_item_id }

    survey_item_responses = parsed_csv_file.map do |row|
      process_row row: row, survey_items: survey_items
    end

    SurveyItemResponse.import survey_item_responses.compact.flatten
  end

  private

  def self.process_row(row:, survey_items:)
    response_date = Date.parse(row['Recorded Date'])
    academic_year = AcademicYear.find_by_date response_date

    response_id = row['Response ID']

    district_code = row['District']
    school_code = row['School']
    return if school_code.nil?

    school = School.find_by_district_code_and_school_code(district_code, school_code)
    return if school.nil?

    survey_items.map do |survey_item|
      next unless SurveyItemResponse.find_by(response_id: response_id, survey_item: survey_item).nil?

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
