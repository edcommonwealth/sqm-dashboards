# frozen_string_literal: true

module ResponseRateCalculator
  TEACHER_RATE_THRESHOLD = 25
  STUDENT_RATE_THRESHOLD = 25
  attr_reader :subcategory, :school, :academic_year

  def initialize(subcategory:, school:, academic_year:)
    @subcategory = subcategory
    @school = school
    @academic_year = academic_year
  end

  def rate
    return 100 if Respondent.where(school: @school, academic_year: @academic_year).count.zero?

    return 0 unless survey_item_count.positive?

    average_responses_per_survey_item = response_count / survey_item_count.to_f

    return 0 unless total_possible_responses.positive?

    response_rate = (average_responses_per_survey_item / total_possible_responses.to_f * 100).round
    cap_at_one_hundred(response_rate)
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
end
