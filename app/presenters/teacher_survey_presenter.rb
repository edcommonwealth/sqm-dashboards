# frozen_string_literal: true

class TeacherSurveyPresenter < DataItemPresenter
  attr_reader :survey_items

  def initialize(measure_id:, survey_items:, has_sufficient_data:, school:, academic_year:)
    super(measure_id:, has_sufficient_data:, school:, academic_year:)
    @survey_items = survey_items
  end

  def title
    'Teacher survey'
  end

  def id
    "teacher-survey-items-#{@measure_id}"
  end

  def reason_for_insufficiency
    'low response rate'
  end

  def descriptions_and_availability
    if @measure_id == '1B-i'
      return [DataAvailability.new('1B-i', 'Items available upon request to Lowell Public Schools.',
                                   true)]
    end

    survey_items.map do |survey_item|
      DataAvailability.new(survey_item.survey_item_id, survey_item.prompt, true)
    end
  end
end
