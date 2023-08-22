class SurveyItemValues
  attr_reader :row, :headers, :genders, :survey_items, :schools, :disaggregation_data

  def initialize(row:, headers:, genders:, survey_items:, schools:, disaggregation_data: nil)
    @row = row
    @headers = include_all_headers(headers:)
    @genders = genders
    @survey_items = survey_items
    @schools = schools
    @disaggregation_data = disaggregation_data

    copy_likert_scores_from_variant_survey_items
    row["Income"] = income
    row["Raw Income"] = raw_income
  end

  # Some survey items have variants, i.e.  a survey item with an id of s-tint-q1 might have a variant that looks like s-tint-q1-1.  We must ensure that all variants in the form of s-tint-q1-1 have a matching pair.
  # We don't ensure that ids in the form of s-tint-q1 have a matching pair because not all questions have variants
  def include_all_headers(headers:)
    alternates = headers.filter(&:present?)
                        .filter { |header| header.end_with? "-1" }
    alternates.each do |header|
      main = header.sub(/-1\z/, "")
      headers.push(main) unless headers.include?(main)
    end
    headers
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
      dese_headers = ["DESE ID", "Dese ID", "DeseId", "DeseID", "School", "school"]
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

  def lasid
    @lasid ||= value_from(pattern: /LASID/i)
  end

  def raw_income
    @raw_income ||= value_from(pattern: /Low\s*Income|Raw\s*Income/i)
    return @raw_income if @raw_income.present?

    return "Unknown" unless disaggregation_data.present?

    disaggregation = disaggregation_data[[lasid, district.name, academic_year.range]]
    return "Unknown" unless disaggregation.present?

    @raw_income ||= disaggregation.income
  end

  # TODO: - rename these cases
  def income
    @income ||= value_from(pattern: /^Income$/i)
    return @income if @income.present?

    @income ||= case raw_income
                in /Free\s*Lunch|Reduced\s*Lunch|Low\s*Income/i
                  "Economically Disadvantaged - Y"
                in /Not\s*Eligible/i
                  "Economically Disadvantaged - N"
                else
                  "Unknown"
                end
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
    headers.select(&:present?)
           .reject { |key, _value| key.start_with? "Q" }
           .reject { |key, _value| key.end_with? "-1" }
           .map { |header| row[header] }
  end

  def duration
    @duration ||= value_from(pattern: /Duration|Duration \(in seconds\)|Duration\.\.\(in\.seconds\)/i)
  end

  def valid?
    valid_duration? && valid_progress? && valid_grade? && valid_sd?
  end

  def respondent_type
    return :teacher if headers
                       .filter(&:present?)
                       .filter { |header| header.start_with? "t-" }.count > 0

    :student
  end

  def survey_type
    survey_item_ids = headers
                      .filter(&:present?)
                      .reject { |header| header.end_with?("-1") }
                      .filter { |header| header.start_with?("t-", "s-") }

    SurveyItem.survey_type(survey_item_ids:)
  end

  def valid_duration?
    return true if duration.nil? || duration == "" || duration.downcase == "n/a" || duration.downcase == "na"

    span_in_seconds = duration.to_i
    return span_in_seconds >= 300 if survey_type == :teacher
    return span_in_seconds >= 240 if survey_type == :standard
    return span_in_seconds >= 100 if survey_type == :short_form

    true
  end

  def valid_progress?
    progress = row["Progress"]
    return true if progress.nil? || progress == "" || progress.downcase == "n/a" || progress.downcase == "na"

    progress = progress.to_i
    progress.to_i >= 25
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
    return true if survey_type == :early_education

    survey_item_headers = headers.filter(&:present?).filter { |header| header.start_with?("s-", "t-") }
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
    headers.filter(&:present?).filter { |header| header.end_with? "-1" }.each do |header|
      likert_score = row[header]
      main_item = header.gsub("-1", "")
      row[main_item] = likert_score if likert_score.present? && row[main_item].blank?
    end
  end
end
