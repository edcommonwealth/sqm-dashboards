class ResponseRatePresenter
  attr_reader :focus, :academic_year, :school, :survey_items

  def initialize(focus:, academic_year:, school:)
    @focus = focus
    @academic_year = academic_year
    @school = school
    if focus == :student
      @survey_items = Measure.all.flat_map do |measure|
        measure.student_survey_items_with_sufficient_responses(school:, academic_year:)
      end
    end
    @survey_items = SurveyItem.teacher_survey_items if focus == :teacher
  end

  def date
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:).order(recorded_date: :DESC).first&.recorded_date || Date.today
  end

  def percentage
    return 0 if respondents_count.zero?

    cap_at_100(actual_count.to_f / respondents_count.to_f * 100).round
  end

  def color
    percentage > 75 ? "purple" : "gold"
  end

  def hover_message
    "Percentages based on #{actual_count} out of #{respondents_count.round} #{focus}s completing at least 25% of the survey."
  end

  private

  def cap_at_100(value)
    value > 100 ? 100 : value
  end

  def actual_count
    SurveyItemResponse.where(school:, academic_year:,
                             survey_item: survey_items).select(:response_id).distinct.count
  end

  def respondents_count
    return 0 if respondents.nil?

    count = enrollment if focus == :student
    count = respondents.total_teachers if focus == :teacher
    count
  end

  def enrollment
    SurveyItemResponse.where(school:, academic_year:, grade: grades,
                             survey_item: SurveyItem.student_survey_items)
                      .select(:grade)
                      .distinct
                      .pluck(:grade)
                      .reject(&:nil?)
                      .map do |grade|
      respondents.counts_by_grade[grade]
    end.sum.to_f
  end

  def respondents
    Respondent.find_by(school:, academic_year:)
  end

  def grades
    respondents.counts_by_grade.keys
  end
end
