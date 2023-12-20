# frozen_string_literal: true

class SurveyResponsesDataLoader
  def load_data(filepath:, rules: [Rule::NoRule])
    File.open(filepath) do |file|
      headers = file.first
      headers_array = CSV.parse(headers).first
      all_survey_items = survey_items(headers:)

      file.lazy.each_slice(500) do |lines|
        survey_item_responses = CSV.parse(lines.join, headers:).map do |row|
          process_row(row: SurveyItemValues.new(row:, headers: headers_array, survey_items: all_survey_items, schools:),
                      rules:)
        end
        SurveyItemResponse.import survey_item_responses.compact.flatten, batch_size: 500
      end
    end
  end

  def from_file(file:, rules: [])
    headers = file.gets
    headers_array = CSV.parse(headers).first
    all_survey_items = survey_items(headers:)

    survey_item_responses = []
    row_count = 0
    until file.eof?
      line = file.gets
      next unless line.present?

      CSV.parse(line, headers:).map do |row|
        survey_item_responses << process_row(row: SurveyItemValues.new(row:, headers: headers_array, survey_items: all_survey_items, schools:),
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

  def schools
    @schools = School.school_hash
  end

  def genders
    @genders = Gender.by_qualtrics_code
  end

  def races
    @races = Race.by_qualtrics_code
  end

  def incomes
    @incomes ||= Income.by_slug
  end

  def ells
    @ells ||= Ell.by_designation
  end

  def speds
    @speds ||= Sped.by_designation
  end

  def process_row(row:, rules:)
    return unless row.dese_id?
    return unless row.school.present?

    rules.each do |rule|
      return if rule.new(row:).skip_row?
    end

    process_survey_items(row:)
  end

  def process_survey_items(row:)
    student = Student.find_or_create_by(response_id: row.response_id, lasid: row.lasid)
    student.races.delete_all
    tmp_races = row.races.map do |race| races[race] end
    student.races += tmp_races

    row.survey_items.map do |survey_item|
      likert_score = row.likert_score(survey_item_id: survey_item.survey_item_id) || next

      unless likert_score.valid_likert_score?
        puts "Response ID: #{row.response_id}, Likert score: #{likert_score} rejected" unless likert_score == "NA"
        next
      end
      response = row.survey_item_response(survey_item:)
      create_or_update_response(survey_item_response: response, likert_score:, row:, survey_item:)
    end.compact
  end

  def create_or_update_response(survey_item_response:, likert_score:, row:, survey_item:, student:)
    gender = genders[row.gender]
    grade = row.grade
    income = incomes[row.income.parameterize]
    ell = ells[row.ell]
    sped = speds[row.sped]
    if survey_item_response.present?
      survey_item_response.update!(likert_score:, grade:, gender:, recorded_date: row.recorded_date, income:, ell:,
                                   sped:)
      []
    else
      SurveyItemResponse.new(response_id: row.response_id, academic_year: row.academic_year, school: row.school, survey_item:,
                             likert_score:, grade:, gender:, recorded_date: row.recorded_date, income:, ell:, sped:)
    end
  end

  def survey_items(headers:)
    SurveyItem.where(survey_item_id: get_survey_item_ids_from_headers(headers:))
  end

  def get_survey_item_ids_from_headers(headers:)
    CSV.parse(headers).first
       .filter(&:present?)
       .filter { |header| header.start_with? "t-", "s-" }
  end
end

module StringMonkeyPatches
  def valid_likert_score?
    to_i.between? 1, 5
  end
end

String.include StringMonkeyPatches

