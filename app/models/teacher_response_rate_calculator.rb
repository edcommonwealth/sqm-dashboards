# frozen_string_literal: true

class TeacherResponseRateCalculator < ResponseRateCalculator
  def survey_item_count
    @survey_item_count ||= survey_items_with_sufficient_responses.length
  end

  def survey_items_have_sufficient_responses?
    survey_item_count.positive?
  end

  def survey_items_with_sufficient_responses
    @survey_items_with_sufficient_responses ||= SurveyItemResponse.teacher_survey_items_with_sufficient_responses(
      school:, academic_year:
    ).slice(*@subcategory.teacher_survey_items.map(&:id))
  end

  def response_count
    @response_count ||= survey_items_with_sufficient_responses&.values&.sum
  end

  def total_possible_responses
    @total_possible_responses ||= respondents.total_educators
  end

  def raw_response_rate
    (average_responses_per_survey_item / total_possible_responses.to_f * 100).round
  end
end
