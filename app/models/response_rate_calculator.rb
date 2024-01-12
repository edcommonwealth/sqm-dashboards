# frozen_string_literal: true

class ResponseRateCalculator
  TEACHER_RATE_THRESHOLD = 25
  STUDENT_RATE_THRESHOLD = 25
  attr_reader :subcategory, :school, :academic_year

  def initialize(subcategory:, school:, academic_year:)
    @subcategory = subcategory
    @school = school
    @academic_year = academic_year
  end

  def rate
    return 100 if population_data_unavailable?

    return 0 unless survey_items_have_sufficient_responses?

    return 0 unless total_possible_responses.positive?

    cap_at_one_hundred(raw_response_rate).round
  end

  def meets_student_threshold?
    rate >= STUDENT_RATE_THRESHOLD
  end

  def meets_teacher_threshold?
    rate >= TEACHER_RATE_THRESHOLD
  end

  private

  def cap_at_one_hundred(response_rate)
    response_rate > 100 ? 100 : response_rate
  end

  def average_responses_per_survey_item
    response_count / survey_item_count.to_f
  end

  def respondents
    @respondents ||= Respondent.by_school_and_year(school:, academic_year:)
  end

  def population_data_unavailable?
    @population_data_unavailable ||= respondents.nil?
  end
end
