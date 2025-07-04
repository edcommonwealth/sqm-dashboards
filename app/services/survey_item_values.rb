class SurveyItemValues
  attr_reader :row, :headers, :survey_items, :schools, :academic_years

  def initialize(row:, headers:, survey_items:, schools:, academic_years: AcademicYear.all)
    @row = row
    # Remove any newlines in headers and
    @headers = normalize_headers(headers:)
    @headers = include_all_headers(headers:)
    @survey_items = survey_items
    @schools = schools
    @academic_years = academic_years

    copy_likert_scores_from_variant_survey_items
    if survey_type == :student
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

    return unless survey_type == :parent

    row["Raw Housing Status"] = raw_housing
    row["Housing Status"] = housing
    row["Home Languages"] = languages.join(",")
    row["Declared Races of Children from Parents"] = races_of_children.join(",")
    row["Declared Genders of Children from Parents"] = genders_of_children.join(",")
  end

  def normalize_headers(headers:)
    headers
      .select(&:present?)
      .map { |item| item.strip }
      .map { |item| item.downcase if item.match(/[stp]-/i) }
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
      if recorded_date.match(%r{\d+/\d+/\d+})
        Date.strptime(recorded_date, "%m/%d/%Y")
      elsif recorded_date.match(/\d+-\d+-\d+(T|\s)\d+:\d+:\d+/)
        Date.parse(recorded_date)
      else
        puts "Recorded date in unknown format"
      end
    end
  end

  def academic_year
    @academic_year ||= begin
      range = AcademicYear.range_from_date(recorded_date, academic_years.map(&:range))
      academic_years.find { |item| item.range == range }
    end
  end

  def survey_item_response(survey_item:)
    survey_item_responses[[response_id, survey_item.id]]
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

  def employments
    e = value_from(pattern: /^Employment$/i)

    return [] if e.nil? || e.empty?

    e.split(",").map do |item|
      Employment.to_designation(item.strip)
    end
  end

  def education
    Education.to_designation(value_from(pattern: /^Education$/i)&.strip)
  end

  def benefits
    Benefit.to_designation(value_from(pattern: /^Benefits$/i)&.strip)
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
    row[survey_item_id] || row["#{survey_item_id}-1"] || value_from(pattern: /#{survey_item_id}/i)
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

  def genders_of_children
    @genders_of_children ||= [].tap do |gender_codes|
      matches = headers.select do |header|
        #         Explanation:
        # ^: Start of the string.
        # (?!.*text): Negative lookahead — ensures that the word text does not appear anywhere in the string.
        # .*?: Lazily match any characters (to get to the word gender).
        # gender: Match the word gender
        header.match(/^(?!.*text).*?gender/i)
      end

      matches.each do |match|
        code = row[match]&.strip
        gender_codes << Gender.qualtrics_code_from(code).to_i unless code.nil?
      end
      gender_codes << 99 if gender_codes.empty?
    end.uniq.sort
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
                             .map { |word| word.split(/\s+and\s+/i) }
                             .flatten
                             .reject(&:blank?)
                             .map { |race| Race.qualtrics_code_from(race) }
                             .map(&:to_i)

      # Only check the secondary hispanic column if we don't have self reported data and are relying on SIS data
      if self_report.nil? && sis.present?
        hispanic = value_from(pattern: /Hispanic\s*Latino/i)&.downcase
        race_codes = race_codes.reject { |code| code == 5 } if ["true", "1"].include?(hispanic) || race_codes.count == 1
        race_codes = race_codes.push(4) if %w[true 1].include?(hispanic)
      end

      Race.normalize_race_list(race_codes)
    end
  end

  def races_of_children
    race_codes = []

    matches = headers.select do |header|
      header.match(/^Race$|^Race-\d+/i)
    end

    matches.each do |match|
      row[match]&.split(",")&.each do |item|
        race_codes << item&.strip&.to_i
      end
    end
    Race.normalize_race_list(race_codes.sort)
  end

  def lasid
    @lasid ||= value_from(pattern: /LASID/i) || ""
  end

  def raw_income
    @raw_income ||= value_from(pattern: /Low\s*Income|Raw\s*Income|SES-\s*SIS|EconDisadvantaged|Income\s*SIS|DirectCert/i)
  end

  def income
    @income ||= Income.to_designation(raw_income)
  end

  def raw_ell
    @raw_ell ||= value_from(pattern: /EL Student First Year|Raw\s*ELL|ELL-*\s*SIS|English Learner|ELL Status- SIS/i)
  end

  def ell
    @ell ||= Ell.to_designation(raw_ell)
  end

  def raw_sped
    @raw_sped ||= value_from(pattern: /Special\s*Ed\s*Status|Raw\s*SpEd|SpEd-\s*SIS|SPED/i)
  end

  def sped
    @sped ||= Sped.to_designation(raw_sped)
  end

  def raw_housing
    @raw_housing ||= value_from(pattern: /Housing/i)
  end

  def housing
    @housing ||= Housing.to_designation(raw_housing)
  end

  def raw_language
    @raw_language ||= value_from(pattern: /^Language$/i) || ""
  end

  def languages
    @languages ||= [].tap do |languages|
      if raw_language.present?
        raw_language.split(",").each do |item|
          languages << Language.to_designation(item)
        end
      end
    end
  end

  def number_of_children
    @number_of_children ||= value_from(pattern: /Number\s*Of\s*Children/i).to_i
  end

  def value_from(pattern:)
    output = nil
    matches = headers.select do |header|
      pattern.match(header)
    end

    matches.each do |match|
      output ||= row[match]&.strip
    end

    output = output.delete("\u0000") if output.present?
    output = output.delete("\x00") if output.present?
    output.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') if output.present?
    output
  end

  def sanitized_headers
    @sanitized_headers ||= headers.select(&:present?)
                                  .reject { |key, _value| key.start_with? "Q" }
                                  .reject { |key, _value| key.match?(/^[stp]-\w*-\w*-1$/i) }
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

    return :parent if headers
                      .filter(&:present?)
                      .filter { |header| header.start_with? "p-" }.count > 0

    :student
  end

  def survey_type
    @survey_type ||= SurveyItem.survey_type(survey_item_ids:)
  end

  def survey_item_ids
    @survey_item_ids ||= sanitized_headers.filter { |header| header.start_with?("t-", "s-", "p-") }
  end

  def valid_duration?
    return true if duration.nil? || duration == "" || duration.downcase == "n/a" || duration.downcase == "na"

    span_in_seconds = duration.to_i
    return span_in_seconds >= 300 if survey_type == :teacher
    return span_in_seconds >= 240 if survey_type == :standard
    return span_in_seconds >= 100 if survey_type == :short_form
    return span_in_seconds >= 120 if survey_type == :parent

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
    return true if survey_type == :parent

    false
  end

  def valid_grade?
    return true if grade.nil?

    return true if respondent_type == :teacher
    return true if survey_type == :parent

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
    return true if survey_type == :parent

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
