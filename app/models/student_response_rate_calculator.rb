# frozen_string_literal: true

class StudentResponseRateCalculator < ResponseRateCalculator
  def raw_response_rate
    rates_by_grade.values.length.positive? ? weighted_average : 0
  end

  def weighted_average
    num_possible_responses = 0.0
    rates_by_grade.keys.map do |grade|
      num_possible_responses += enrollment_by_grade[grade]
    end
    rates_by_grade.map do |grade, rate|
      rate * (enrollment_by_grade[grade] / num_possible_responses)
    end.sum
  end

  def rates_by_grade
    @rates_by_grade ||= enrollment_by_grade.map do |grade, num_of_students_in_grade|
      sufficient_survey_items = survey_items_with_sufficient_responses(grade:).keys
      actual_response_count_for_grade = SurveyItemResponse.where(school:, academic_year:, grade:,
                                                                 survey_item: sufficient_survey_items).count.to_f
      count_of_survey_items_with_sufficient_responses = survey_item_count(grade:)
      if count_of_survey_items_with_sufficient_responses.nil? || count_of_survey_items_with_sufficient_responses.zero? || num_of_students_in_grade.nil? || num_of_students_in_grade.zero?
        next nil
      end

      [grade, actual_response_count_for_grade / count_of_survey_items_with_sufficient_responses / num_of_students_in_grade * 100]
    end.compact.to_h
  end

  def enrollment_by_grade
    @enrollment_by_grade ||= respondents.counts_by_grade
  end

  def total_enrollment
    respondents.counts_by_grade.sum
  end

  def survey_items_have_sufficient_responses?
    rates_by_grade.values.length.positive?
  end

  def survey_items_with_sufficient_responses(grade:)
    threshold = 10
    quarter_of_grade = enrollment_by_grade[grade] / 4
    threshold = threshold > quarter_of_grade ? quarter_of_grade : threshold
    SurveyItem.joins('inner join survey_item_responses on  survey_item_responses.survey_item_id = survey_items.id')
              .student_survey_items
              .where("survey_item_responses.school": school, "survey_item_responses.academic_year": academic_year, "survey_item_responses.grade": grade, "survey_item_responses.survey_item_id": subcategory.survey_items.student_survey_items)
              .group('survey_items.id')
              .having("count(*) >= #{threshold}")
              .count
  end

  def survey_item_count(grade:)
    survey_items_with_sufficient_responses(grade:).count
  end

  def respondents
    @respondents ||= Respondent.find_by(school:, academic_year:)
  end

  def total_possible_responses
    @total_possible_responses ||= begin
      return 0 unless respondents.present?

      respondents.total_students
    end
  end
end
