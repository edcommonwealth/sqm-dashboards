class TeacherResponseRate
  include ResponseRate

  def survey_item_count
    @survey_item_count ||= @subcategory.measures.map do |measure|
      measure.teacher_survey_items.reject do |survey_item|
        survey_item.survey_item_responses.where(school: @school, academic_year: @academic_year).count == 0
      end.count
    end.sum
  end

  def response_count
    @response_count ||= @subcategory.measures.map do |measure|
      measure.teacher_survey_items.map do |survey_item|
        survey_item.survey_item_responses.where(school: @school,
                                                academic_year: @academic_year).exclude_boston.count
      end.sum
    end.sum
  end

  def total_possible_responses
    @total_possible_responses ||= begin
      total_responses = Respondent.where(school: @school, academic_year: @academic_year).first
      return 0 unless total_responses.present?

      total_responses.total_teachers
    end
  end
end
