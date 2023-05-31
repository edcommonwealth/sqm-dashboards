class SurveyItemValues
  attr_reader :row, :headers, :genders, :survey_items, :schools

  def initialize(row:, headers:, genders:, survey_items:, schools:)
    @row = row
    @headers = headers
    @genders = genders
    @survey_items = survey_items
    @schools = schools
  end

  def dese_id?
    dese_id.present?
  end

  def recorded_date
    @recorded_date ||= begin
      recorded_date = value_from(pattern: /Recorded\s*Date/i)
      Date.parse(recorded_date)
    end
  end

  def academic_year
    @academic_year ||= AcademicYear.find_by_date recorded_date
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
    @response_id ||= value_from(pattern: /Response\s*ID/i)
  end

  def dese_id
    @dese_id ||= begin
      dese_id = nil
      dese_headers = ['DESE ID', 'Dese ID', 'DeseId', 'DeseID', 'School', 'school']
      school_headers = headers.select { |header| /School-\s\w/.match(header) }
      dese_headers << school_headers
      dese_headers.flatten.each do |header|
        dese_id ||= row[header]
      end

      dese_id.to_i
    end
  end

  def likert_score(survey_item_id:)
    row[survey_item_id] || row["#{survey_item_id}-1"]
  end

  def school
    @school ||= schools[dese_id]
  end

  def district
    @district ||= school&.district
  end

  def grade
    @grade ||= begin
      raw_grade = value_from(pattern: /Grade|What grade are you in?/i)

      return nil if raw_grade.blank?

      raw_grade.to_i
    end
  end

  def gender
    gender_code = value_from(pattern: /Gender|What is your gender?|What is your gender? - Selected Choice/i)
    gender_code ||= 99
    gender_code = gender_code.to_i
    gender_code = 4 if gender_code == 3
    gender_code = 99 if gender_code.zero?
    genders[gender_code]
  end

  def value_from(pattern:)
    output = nil
    matches = headers.select do |header|
      pattern.match(header)
    end.map { |item| item.delete("\n") }
    matches.each do |match|
      output ||= row[match]
    end
    output
  end

  def to_a
    copy_likert_scores_from_variant_survey_items
    row.remove_unwanted_columns
  end

  def duration
    @duration ||= value_from(pattern: /Duration|Duration \(in seconds\)|Duration\.\.\(in\.seconds\)/i).to_i
  end

  def valid?
    valid_duration? && valid_progress? && valid_grade? && valid_sd?
  end

  def respondent_type
    return :teacher if headers
                       .filter(&:present?)
                       .filter { |header| header.start_with? 't-' }.count > 0

    :student
  end

  def survey_type
    survey_item_ids = headers
                      .filter(&:present?)
                      .filter { |header| header.start_with?('t-', 's-') }

    SurveyItem.survey_type(survey_item_ids:)
  end

  def valid_duration?
    return duration >= 300 if survey_type == :teacher
    return duration >= 240 if survey_type == :standard
    return duration >= 100 if survey_type == :short_form

    true
  end

  def valid_progress?
    row['Progress'].to_i >= 25
  end

  def valid_grade?
    return true if grade.nil?

    return true if respondent_type == :teacher

    respondents = Respondent.where(school:, academic_year:).first
    if respondents.present? && respondents.counts_by_grade[grade].present?
      enrollment = respondents.counts_by_grade[grade]
    end
    return false if enrollment.nil?

    valid = enrollment > 0
    puts "Invalid grade #{grade} for #{school.name} #{academic_year.formatted_range}" unless valid
    valid
  end

  def valid_sd?
    survey_item_headers = headers.filter(&:present?).filter { |header| header.start_with?('s-', 't-') }
    likert_scores = []
    survey_item_headers.each do |header|
      likert_scores << likert_score(survey_item_id: header).to_i
    end
    likert_scores = likert_scores.compact.reject(&:zero?)
    return false if likert_scores.count < 2

    !likert_scores.stdev.zero?
  end

  def valid_school?
    school.present?
  end

  private

  def copy_likert_scores_from_variant_survey_items
    headers.filter(&:present?).filter { |header| header.end_with? '-1' }.each do |header|
      likert_score = row[header]
      main_item = header.gsub('-1', '')
      row[main_item] = likert_score if likert_score.present?
    end
  end
end

module RowMonkeyPatches
  def remove_unwanted_columns
    to_h.filter do |key, _value|
      key.present?
    end.reject { |key, _value| key.start_with? 'Q' }.reject { |key, _value| key.end_with? '-1' }.values
  end
end

CSV::Row.include RowMonkeyPatches
