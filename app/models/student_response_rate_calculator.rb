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
      responses = survey_items_with_sufficient_responses(grade:)
      actual_response_count_for_grade = responses.values.sum.to_f
      count_of_survey_items_with_sufficient_responses = responses.count
      if actual_response_count_for_grade.nil? || count_of_survey_items_with_sufficient_responses.nil? || count_of_survey_items_with_sufficient_responses.zero? || num_of_students_in_grade.nil? || num_of_students_in_grade.zero?
        next nil
      end

      rate = actual_response_count_for_grade / count_of_survey_items_with_sufficient_responses / num_of_students_in_grade * 100
      [grade, rate]
    end.compact.to_h
  end

  def enrollment_by_grade
    @enrollment_by_grade ||= respondents.enrollment_by_grade
  end

  def survey_items_have_sufficient_responses?
    rates_by_grade.values.length.positive?
  end

  def survey_items_with_sufficient_responses(grade:)
    @survey_items_with_sufficient_responses ||= Hash.new do |memo, grade|
      threshold = 10
      quarter_of_grade = enrollment_by_grade[grade] / 4
      threshold = threshold > quarter_of_grade ? quarter_of_grade : threshold

      si = SurveyItemResponse.student_survey_items_with_sufficient_responses_by_grade(school:,
                                                                                      academic_year:)
      si = si.reject do |_key, value|
        value < threshold
      end

      ssi = @subcategory.student_survey_items.map(&:id)
      grade_array = Array.new(ssi.length, grade)

      memo[grade] = si.slice(*grade_array.zip(ssi))
    end
    @survey_items_with_sufficient_responses[grade]
  end

  def total_possible_responses
    @total_possible_responses ||= begin
      return 0 unless respondents.present?

      respondents.total_students
    end
  end
end
