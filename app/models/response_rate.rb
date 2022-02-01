class ResponseRate
  def initialize(subcategory:, school:, academic_year:)
    @subcategory = subcategory
    @school = school
    @academic_year = academic_year
  end

  def student
    return 0 unless student_survey_item_count.positive?

    average_responses_per_survey_item = student_response_count / student_survey_item_count

    return 0 unless total_possible_student_responses.positive?

    (average_responses_per_survey_item / total_possible_student_responses * 100).round
  end

  def teacher
    return 0 unless teacher_survey_item_count.positive?

    average_responses_per_survey_item = teacher_response_count / teacher_survey_item_count

    return 0 unless total_possible_teacher_responses.positive?

    (average_responses_per_survey_item / total_possible_teacher_responses * 100).round
  end

  private

  def total_possible_student_responses
    @total_possible_student_responses ||= total_possible_responses do |responses|
      responses.total_students
    end
  end

  def total_possible_teacher_responses
    @total_possible_teacher_responses ||= total_possible_responses do |responses|
      responses.total_teachers
    end
  end

  def total_possible_responses
    total_responses = Respondent.where(school: @school, academic_year: @academic_year).first
    return 0 unless total_responses.present?

    yield total_responses
  end

  def student_response_count
    @student_response_count ||= SurveyItemResponse.student_responses_for_measures(@subcategory.measures, @school,
                                                                                 @academic_year).count.to_f
  end

  def teacher_response_count
    @teacher_response_count ||= SurveyItemResponse.teacher_responses_for_measures(@subcategory.measures, @school,
                                                                                 @academic_year).count.to_f
  end

  def student_survey_item_count
    @student_survey_item_count ||= @subcategory.measures.map do |measure|
      measure.student_survey_items.count
    end.sum.to_f
  end

  def teacher_survey_item_count
    @teacher_survey_item_count ||= @subcategory.measures.map do |measure|
      measure.teacher_survey_items.count
    end.sum.to_f
  end
end
