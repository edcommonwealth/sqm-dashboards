# frozen_string_literal: true

class TeacherResponseRateCalculator < ResponseRateCalculator
  def survey_item_count
    @survey_item_count ||= begin
      survey_items = @subcategory.measures.flat_map(&:teacher_survey_items)

      SurveyItem.joins('inner join survey_item_responses on  survey_item_responses.survey_item_id = survey_items.id')
                .teacher_survey_items
                .where("survey_item_responses.school": school, "survey_item_responses.academic_year": academic_year, "survey_item_responses.survey_item_id": survey_items)
                .group('survey_items.id')
                .having('count(*) >= 0').count.length
    end
  end

  def survey_items_have_sufficient_responses?
    survey_item_count.positive?
  end

  def response_count
    @response_count ||= @subcategory.measures.map do |measure|
      measure.teacher_survey_items.map do |survey_item|
        survey_item.survey_item_responses.where(school:,
                                                academic_year:).exclude_boston.count
      end.sum
    end.sum
  end

  def total_possible_responses
    @total_possible_responses ||= begin
      total_responses = Respondent.where(school:, academic_year:).first
      return 0 unless total_responses.present?

      total_responses.total_teachers
    end
  end

  def raw_response_rate
    (average_responses_per_survey_item / total_possible_responses.to_f * 100).round
  end
end
