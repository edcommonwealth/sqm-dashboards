class ResponseRate
  def initialize(subcategory:, school:, academic_year:)
    @subcategory = subcategory
    @school = school
    @academic_year = academic_year
  end

  def student
    @student_response_rate ||= begin
      return 0 unless student_survey_item_count.positive?

      average_responses_per_survey_item = student_response_count / student_survey_item_count

      return 0 unless total_possible_student_responses.positive?

      (average_responses_per_survey_item / total_possible_student_responses * 100).round
    end
  end

  def teacher
    @teacher_response_rate ||= begin
      return 0 unless teacher_survey_item_count.positive?

      average_responses_per_survey_item = teacher_response_count / teacher_survey_item_count

      return 0 unless total_possible_teacher_responses.positive?

      (average_responses_per_survey_item / total_possible_teacher_responses * 100).round
    end
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
    @student_response_count ||= response_count do |measure|
      next 0 unless measure.includes_student_survey_items?

      SurveyItemResponse.student_responses_for_measure(measure, @school, @academic_year).count
    end
  end

  def teacher_response_count
    @teacher_response_count ||= response_count do |measure|
      next 0 unless measure.includes_teacher_survey_items?

      SurveyItemResponse.teacher_responses_for_measure(measure, @school, @academic_year).count
    end
  end

  def response_count(&block)
    @subcategory.measures.map(&block).sum
  end

  def student_survey_item_count
    @student_survey_item_count ||= survey_item_count do |measure|
      measure.student_survey_items.count
    end
  end

  def teacher_survey_item_count
    @teacher_survey_item_count ||= survey_item_count do |measure|
      measure.teacher_survey_items.count
    end
  end

  def survey_item_count(&block)
    @subcategory.measures.map(&block).sum
  end
end
