class StudentSurveyPresenter < DataItemPresenter
  def initialize(measure_id:, survey_items:)
    super(measure_id: measure_id)
    @survey_items = survey_items
  end

  def title
    "Student survey"
  end

  def id
    "student-survey-items-#{@measure_id}"
  end

  def item_descriptions
    @survey_items.map(&:prompt)
  end
end
