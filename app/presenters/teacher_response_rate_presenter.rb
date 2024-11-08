class TeacherResponseRatePresenter < ResponseRatePresenter
  def initialize(focus:, academic_year:, school:)
    super(focus:, academic_year:, school:)
    @survey_items = SurveyItem.teacher_survey_items
  end

  def actual_count
    response_count_for_survey_items(survey_items:)
  end

  def respondents_count
    return 0 if respondents.nil?

    respondents.total_teachers
  end
end
