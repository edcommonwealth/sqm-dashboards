class ResponseRatePresenter
  attr_reader :focus, :academic_year, :school, :survey_items

  def initialize(focus:, academic_year:, school:)
    @focus = focus
    @academic_year = academic_year
    @school = school
    @survey_items = SurveyItem.student_survey_items if focus == :student
    @survey_items = SurveyItem.teacher_survey_items if focus == :teacher
  end

  def date
    SurveyItemResponse.where(survey_item: survey_items, school:).order(updated_at: :DESC).first&.updated_at || Date.new
  end

  def percentage
    return 0 if respondents_count.zero?

    cap_at_100(actual_count.to_f / respondents_count.to_f * 100).round
  end

  def color
    percentage > 75 ? 'purple' : 'gold'
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
