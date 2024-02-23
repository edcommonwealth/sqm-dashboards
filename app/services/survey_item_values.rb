class SurveyItemValues
  attr_reader :row, :headers, :survey_items, :schools

  def initialize(row:, headers:, survey_items:, schools:)
    @row = row
    # Remove any newlines in headers
    headers = headers.map { |item| item.delete("\n") if item.present? }
    @headers = include_all_headers(headers:)
    @survey_items = survey_items
    @schools = schools

    copy_likert_scores_from_variant_survey_items
    row["Income"] = income
    row["Raw Income"] = raw_income
    row["Raw ELL"] = raw_ell
    row["ELL"] = ell
    row["Raw SpEd"] = raw_sped
    row["SpEd"] = sped
    row["Progress Count"] = progress
    row["Race"] ||= races.join(",")
    row["Gender"] ||= gender

    copy_data_to_main_column(main: /Race/i, secondary: /Race Secondary|Race-1/i)
    copy_data_to_main_column(main: /Gender/i, secondary: /Gender Secondary|Gender-1/i)
  end

  def copy_data_to_main_column(main:, secondary:)
    main_column = headers.find { |header| main.match(header) }
    row[main_column] = value_from(pattern: secondary) if row[main_column].nil?
  end

  # Some survey items have variants, i.e.  a survey item with an id of s-tint-q1 might have a variant that looks like s-tint-q1-1.  We must ensure that all variants in the form of s-tint-q1-1 have a matching pair.
  # We don't ensure that ids in the form of s-tint-q1 have a matching pair because not all questions have variants
  def include_all_headers(headers:)
    alternates = headers.filter(&:present?)
                        .filter { |header| header.match?(/^[st]-\w*-\w*-1$/i) }
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
      puts recorded_date
      date = nil
      begin
        date = Date.parse(recorded_date)
      rescue StandardError => e
        date = Date.strptime(recorded_date, "%m/%d/%Y")
      end
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
      dese_id = value_from(pattern: /Dese\s*ID/i)
      dese_id ||= value_from(pattern: /^School$/i)
      dese_id ||= value_from(pattern: /School-\s*\w/i)
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
    @gender ||= begin
      gender_code ||= value_from(pattern: /Gender self report/i)
      gender_code ||= value_from(pattern: /^Gender$/i)
      gender_code ||= value_from(pattern: /What is your gender?|What is your gender? - Selected Choice/i)
      gender_code ||= value_from(pattern: /Gender-\s*SIS/i)
      gender_code ||= value_from(pattern: /Gender-\s*Qcode/i)
      gender_code ||= value_from(pattern: /Gender - do not use/i)
      gender_code ||= value_from(pattern: /Gender/i)
      Gender.qualtrics_code_from(gender_code)
    end
  end

  def races
    @races ||= begin
      race_codes ||= self_report = value_from(pattern: /Race\s*self\s*report/i)
      race_codes ||= value_from(pattern: /^RACE$/i)
      race_codes ||= value_from(pattern: %r{What is your race/ethnicity?(Please select all that apply) - Selected Choice}i)
      race_codes ||= value_from(pattern: /Race Secondary/i)
      race_codes ||= sis ||= value_from(pattern: /Race-\s*SIS/i)
      race_codes ||= sis ||= value_from(pattern: /Race\s*-\s*Qcodes/i)
      race_codes ||= value_from(pattern: /RACE/i) || ""
      race_codes ||= []

      race_codes = race_codes.split(",")
                             .map do |word|
                     word.split(/\s+and\s+/i)
                   end.flatten
                      .reject(&:blank?)
                      .map { |race| Race.qualtrics_code_from(race) }.map(&:to_i)

      # Only check the secondary hispanic column if we don't have self reported data and are relying on SIS data
      if self_report.nil? && sis.present?
        hispanic = value_from(pattern: /Hispanic\s*Latino/i)&.downcase
        race_codes = race_codes.reject { |code| code == 5 } if hispanic == "true" && race_codes.count == 1
        race_codes = race_codes.push(4) if hispanic == "true"
      end

      Race.normalize_race_list(race_codes)
    end
  end

  def lasid
    @lasid ||= value_from(pattern: /LASID/i)
  end

  def raw_income
    @raw_income ||= value_from(pattern: /Low\s*Income|Raw\s*Income|SES-\s*SIS/i)
  end

  def income
    @income ||= Income.to_designation(raw_income)
  end

  def raw_ell
    @raw_ell ||= value_from(pattern: /EL Student First Year|Raw\s*ELL|ELL-\s*SIS/i)
  end

  def ell
    @ell ||= Ell.to_designation(raw_ell)
  end

  def raw_sped
    @raw_sped ||= value_from(pattern: /Special\s*Ed\s*Status|Raw\s*SpEd|SpEd-\s*SIS/i)
  end

  def sped
    @sped ||= Sped.to_designation(raw_sped)
  end

  def value_from(pattern:)
    output = nil
    matches = headers.select do |header|
      pattern.match(header)
    end.map { |item| item.delete("\n") }

    matches.each do |match|
      output ||= row[match]&.strip
    end

    return nil if output&.match?(%r{^#*N/*A$}i) || output.blank?

    output
  end

  def sanitized_headers
    @sanitized_headers ||= headers.select(&:present?)
                                  .reject { |key, _value| key.start_with? "Q" }
                                  .reject { |key, _value| key.match?(/^[st]-\w*-\w*-1$/i) }
  end

  def to_a
    sanitized_headers.map { |header| row[header] }
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
    @survey_type ||= SurveyItem.survey_type(survey_item_ids:)
  end

  def survey_item_ids
    @survey_item_ids ||= sanitized_headers.filter { |header| header.start_with?("t-", "s-") }
  end

  def valid_duration?
    return true if duration.nil? || duration == "" || duration.downcase == "n/a" || duration.downcase == "na"

    span_in_seconds = duration.to_i
    return span_in_seconds >= 300 if survey_type == :teacher
    return span_in_seconds >= 240 if survey_type == :standard
    return span_in_seconds >= 100 if survey_type == :short_form

    true
  end

  def progress
    survey_item_ids.reject { |header| row[header].nil? }.count
  end

  def valid_progress?
    return false if progress.nil?

    return progress >= 12 if survey_type == :teacher
    return progress >= 11 if survey_type == :standard
    return progress >= 5 if survey_type == :short_form
    return progress >= 5 if survey_type == :early_education

    false
  end

  def valid_grade?
    return true if grade.nil?

    return true if respondent_type == :teacher

    respondents = Respondent.where(school:, academic_year:).first
    if respondents.present? && respondents.enrollment_by_grade[grade].present?
      enrollment = respondents.enrollment_by_grade[grade]
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
