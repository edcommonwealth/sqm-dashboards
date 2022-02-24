module ResponseRate
  TEACHER_RATE_THRESHOLD = 0.25
  STUDENT_RATE_THRESHOLD = 0.25

  def initialize(subcategory:, school:, academic_year:)
    @subcategory = subcategory
    @school = school
    @academic_year = academic_year
  end

  def rate
    return 0 unless survey_item_count.positive?

    average_responses_per_survey_item = response_count / survey_item_count.to_f

    return 0 unless total_possible_responses.positive?

    (average_responses_per_survey_item / total_possible_responses.to_f * 100).round
  end

  def meets_student_threshold?
    rate >= STUDENT_RATE_THRESHOLD * 100
  end

  def meets_teacher_threshold?
    rate >= TEACHER_RATE_THRESHOLD * 100
  end
end
