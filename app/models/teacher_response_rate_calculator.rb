# frozen_string_literal: true

class TeacherResponseRateCalculator < ResponseRateCalculator
  def survey_item_count
    @survey_item_count ||= survey_items_with_sufficient_responses.length
  end

  def survey_items_have_sufficient_responses?
    survey_item_count.positive?
  end

  def survey_items_with_sufficient_responses
    SurveyItem.joins("inner join survey_item_responses on  survey_item_responses.survey_item_id = survey_items.id")
              .teacher_survey_items
              .where("survey_item_responses.school": school, "survey_item_responses.academic_year": academic_year, "survey_item_responses.survey_item_id": @subcategory.survey_items.teacher_survey_items)
              .group("survey_items.id")
              .having("count(*) >= 0").count
  end

  def response_count
    @response_count ||= survey_items_with_sufficient_responses.values.sum
  end

  def total_possible_responses
    @total_possible_responses ||= respondents.total_teachers
  end

  def raw_response_rate
    (average_responses_per_survey_item / total_possible_responses.to_f * 100).round
  end
end
