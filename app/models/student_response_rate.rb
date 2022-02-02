class StudentResponseRate < ResponseRate
  def rate
    super
  end

  private

  def survey_item_count
    @student_survey_item_count ||= @subcategory.measures.map do |measure|
      measure.student_survey_items.count
    end.sum
  end

  def response_count
    @student_response_count ||= SurveyItemResponse.student_responses_for_measures(@subcategory.measures, @school,
                                                                                  @academic_year).count
  end

  def total_possible_responses
    @total_possible_student_responses ||= begin
      total_responses = Respondent.where(school: @school, academic_year: @academic_year).first
      return 0 unless total_responses.present?

      total_responses.total_students
    end
  end
end
