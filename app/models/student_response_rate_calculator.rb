# frozen_string_literal: true

class StudentResponseRateCalculator < ResponseRateCalculator
  private

  def raw_response_rate
    # def rate
    # check to see if enrollment data is available
    #   if not, run the dese loader to get the data
    #   then upload the enrollment data into the db
    #
    # if you still don't see enrollment for the school, raise an error and return 100 from this method
    #
    #  Get the enrollment information from the db
    #  Get the list of all grades
    #  For each grade, get the survey items with data
    #
    #
    #  All methods below will need to specify a grade

    (average_responses_per_survey_item / total_possible_responses.to_f * 100).round
  end

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

  def grades_with_sufficient_responses
    SurveyItemResponse.where(school:, academic_year:,
                             survey_item: subcategory.survey_items.student_survey_items).where.not(grade: nil)
                      .group(:grade)
                      .select(:response_id)
                      .distinct(:response_id)
                      .count.reject do |_key, value|
      value < 10
    end.keys
  end
end
