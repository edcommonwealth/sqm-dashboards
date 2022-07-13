# frozen_string_literal: true

class StudentResponseRateCalculator < ResponseRateCalculator
  private

  def survey_item_count
    @survey_item_count ||= begin
      survey_items = SurveyItem.includes(%i[scale
                                            measure]).student_survey_items.where("scale.measure": @subcategory.measures)
      survey_items = survey_items.where(on_short_form: true) if survey.form == 'short'
      survey_items = survey_items.reject do |survey_item|
        survey_item.survey_item_responses.where(school:, academic_year:).none?
      end
      survey_items.count
    end
  end

  def response_count
    @response_count ||= @subcategory.measures.map do |measure|
      measure.student_survey_items.map do |survey_item|
        next 0 if survey.form == 'short' && survey_item.on_short_form == false

        survey_item.survey_item_responses.where(school:,
                                                academic_year:).exclude_boston.count
      end.sum
    end.sum
  end

  def total_possible_responses
    @total_possible_responses ||= begin
      total_responses = Respondent.find_by(school:, academic_year:)
      return 0 unless total_responses.present?

      total_responses.total_students
    end
  end
end
