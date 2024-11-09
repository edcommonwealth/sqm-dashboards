class ParentResponseRatePresenter < ResponseRatePresenter
  def initialize(academic_year:, school:)
    super(academic_year:, school:)
    @survey_items = SurveyItem.parent_survey_items
  end

  def actual_count
    SurveyItemResponse.includes(:parent).where(school:, academic_year:).where.not(parent_id: nil)
                      .select(:parent_id)
                      .distinct
                      .map { |response| response.parent&.number_of_children }
                      .compact.sum
  end

  def respondents_count
    return 0 if respondents.nil?

    respondents.total_students
  end

  def focus
    "parent"
  end
end
