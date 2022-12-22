class SurveyItemValues
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
    row[survey_item_id] || row["#{survey_item_id}-1"]
  end

  def school
    @school ||= School.includes(:district).find_by_dese_id(dese_id)
  end

  def grade
    @grade ||= begin
      raw_grade = (row['grade'] || row['Grade'] || row['What grade are you in?']).to_i
      raw_grade == 0 ? nil : raw_grade
    end
  end

  def gender
    gender_code = row['gender'] || row['Gender'] || row['What is your gender?'] || row['What is your gender? - Selected Choice'] || 99
    gender_code = gender_code.to_i
    gender_code = 4 if gender_code == 3
    gender_code = 99 if gender_code.zero?
    genders[gender_code]
  end
end
