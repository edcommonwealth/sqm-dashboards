class ResponseRatePresenter
  attr_reader :academic_year, :school, :survey_items

  def initialize(academic_year:, school:)
    @academic_year = academic_year
    @school = school
  end

  def date
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:).order(recorded_date: :DESC).first&.recorded_date
  end

  def percentage
    return 0 if respondents_count.nil? || respondents_count.zero?

    cap_at_100(actual_count.to_f / respondents_count.to_f * 100).round
  end

  def color
    percentage > 75 ? "purple" : "gold"
  end

  def date_message
    return "" if date.nil?

    "Response rate as of #{date.to_date.strftime('%m/%d/%y')}"
  end

  def hover_message
    return "" if date.nil?

    "Percentages based on #{actual_count} out of #{respondents_count.round} #{focus}s completing at least 25% of the survey."
  end

  def focus
    raise "please implment method: focus"
  end

  private

  def cap_at_100(value)
    value > 100 ? 100 : value
  end

  def actual_count
    raise "please implement the method: actual_count"
  end

  def response_count_for_survey_items(survey_items:)
    SurveyItemResponse.where(school:, academic_year:,
                             survey_item: survey_items).select(:response_id).distinct.count || 0
  end

  def respondents_count
    raise "please implement the method: respondents_count"
  end

  def enrollment
    SurveyItemResponse.where(school:, academic_year:, grade: grades,
                             survey_item: SurveyItem.student_survey_items)
                      .select(:grade)
                      .distinct
                      .pluck(:grade)
                      .reject(&:nil?)
                      .map do |grade|
      respondents.enrollment_by_grade[grade]
    end.sum.to_f
  end

  def respondents
    @respondents ||= Respondent.by_school_and_year(school:, academic_year:)
  end

  def grades
    respondents.enrollment_by_grade.keys
  end
end
