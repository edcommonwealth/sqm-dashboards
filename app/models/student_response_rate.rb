class StudentResponseRate
  include ResponseRate

  private

  def survey_item_count
    # @survey_item_count ||= @subcategory.measures.map { |measure| measure.student_survey_items.count }.sum
    @survey_item_count ||= begin
      survey = Survey.where(school: @school, academic_year: @academic_year).first
      if survey.form == 'normal'
        SurveyItem.includes(%i[scale measure]).student_survey_items.where("scale.measure": @subcategory.measures).count
      else
        SurveyItem.includes(%i[scale
                               measure]).student_survey_items.where("scale.measure": @subcategory.measures).where(on_short_form: true).count
      end
    end
  end

  def response_count
    @response_count ||= @subcategory.measures.map do |measure|
      measure.student_survey_items.map do |survey_item|
        survey_item.survey_item_responses.where(school: @school, academic_year: @academic_year).count
      end.sum
    end.sum
  end

  def total_possible_responses
    @total_possible_responses ||= begin
      total_responses = Respondent.where(school: @school, academic_year: @academic_year).first
      return 0 unless total_responses.present?

      total_responses.total_students
    end
  end
end
