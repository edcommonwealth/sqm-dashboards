require 'csv'

class SurveyResponsesDataLoader
  def self.load_data(filepath:)
    csv_file = File.read(filepath)

    parsed_csv_file = CSV.parse(csv_file, headers: true)
    survey_items = parsed_csv_file.headers
                         .filter { |header| !header.nil? }
                         .filter { |header| header.start_with? 't-' }
                         .map { |survey_item_id| SurveyItem.find_by_survey_item_id survey_item_id }

    parsed_csv_file.each do |row|
      process_row row: row, survey_items: survey_items
    end
  end

  private

  def self.process_row(row:, survey_items:)
    response_date = Date.parse(row['Recorded Date'])
    academic_year = academic_year date: response_date

    response_id = row['Response ID']

    school_code = row['school_code']
    return if school_code.nil?

    school = school(row: row)
    return if school.nil?

    return unless SurveyItemResponse.find_by_response_id(response_id).nil?

    survey_items.each do |survey_item|
      likert_score = row[survey_item.survey_item_id]
      next if likert_score.nil?
      SurveyItemResponse.create(
        response_id: response_id,
        academic_year: academic_year,
        school: school,
        survey_item: survey_item,
        likert_score: likert_score
      )
    end

  end

  def self.school(row:)
    district_code = row['district_code']
    school_code = row['school_code']
    return nil if school_code.nil?

    School
       .where({district: District.find_by_qualtrics_code(district_code), qualtrics_code: school_code})
       .first
  end

  def self.academic_year(date:)
    if date.month > 7
      ay_range_start = date.year
      ay_range_end = date.year + 1
    else
      ay_range_start = date.year - 1
      ay_range_end = date.year
    end
    AcademicYear.find_by_range("#{ay_range_start}-#{ay_range_end.to_s[2, 3]}")
  end
end