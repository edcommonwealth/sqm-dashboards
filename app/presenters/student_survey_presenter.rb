class StudentSurveyPresenter < DataItemPresenter
  def initialize(measure_id:, survey_items:, has_sufficient_data:)
    super(measure_id: measure_id, has_sufficient_data: has_sufficient_data)
    @survey_items = survey_items
  end

  def title
    'Student survey'
  end

  def id
    "student-survey-items-#{@measure_id}"
  end

  def item_descriptions
    @survey_items.map(&:prompt)
  end

  def reason_for_insufficiency
    'low response rate'
  end
end
