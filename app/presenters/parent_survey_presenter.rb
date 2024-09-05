# frozen_string_literal: true

class ParentSurveyPresenter < DataItemPresenter
  attr_reader :survey_items

  def initialize(measure_id:, survey_items:, has_sufficient_data:, school:, academic_year:)
    super(measure_id:, has_sufficient_data:, school:, academic_year:)
    @survey_items = survey_items
  end

  def title
    "Parent survey"
  end

  def id
    "parent-survey-items-#{measure_id}"
  end

  def reason_for_insufficiency
    "low response rate"
  end

  def descriptions_and_availability
    survey_items.map(&:description)
  end
end
