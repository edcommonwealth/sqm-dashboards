class TeacherResponseRate < ResponseRate
  def rate
    cap_at_100(super)
  end

  private

  def cap_at_100(response_rate)
    response_rate > 100 ? 100 : response_rate
  end

  def survey_item_count
    @teacher_survey_item_count ||= @subcategory.measures.map do |measure|
      measure.teacher_survey_items.count
    end.sum
  end

  def response_count
    @teacher_response_count ||= SurveyItemResponse.teacher_responses_for_measures(@subcategory.measures, @school,
                                                                                  @academic_year).count
  end

  def total_possible_responses
    @total_possible_teacher_responses ||= begin
      total_responses = Respondent.where(school: @school, academic_year: @academic_year).first
      return 0 unless total_responses.present?

      total_responses.total_teachers
    end
  end
end