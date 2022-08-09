# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module RacialScore
        def race_score(measure:, school:, academic_year:, race:)
          rate = response_rate(school:, academic_year:, measure:)
          return Score.new(0, false, false, false) unless rate.meets_student_threshold

          survey_items = measure.student_survey_items

          students = StudentRace.where(race:).pluck(:student_id).uniq
          averages = grouped_responses(school:, academic_year:, survey_items:, students:)
          number_of_responses = total_responses(school:, academic_year:, students:, survey_items:)
          scorify(responses: averages, number_of_responses:)
        end

        private

        def grouped_responses(school:, academic_year:, survey_items:, students:)
          SurveyItemResponse.where(school:,
                                   academic_year:,
                                   student: students,
                                   survey_item: survey_items)
                            .group(:survey_item_id)
                            .average(:likert_score)
        end

        def total_responses(school:, academic_year:, students:, survey_items:)
          @total_responses ||= SurveyItemResponse.where(school:,
                                                        academic_year:,
                                                        student: students,
                                                        survey_item: survey_items).count
        end

        def response_rate(school:, academic_year:, measure:)
          @response_rate ||= Hash.new do |memo, (school, academic_year)|
            memo[[school, academic_year]] =
              ResponseRate.find_by(subcategory: measure.subcategory, school:, academic_year:)
          end

          @response_rate[[school, academic_year]]
        end

        def scorify(responses:, number_of_responses:)
          averages = bubble_up_averages(responses:)
          average = averages.average

          meets_student_threshold = sufficient_responses(averages:, number_of_responses:)
          average = 0 unless meets_student_threshold

          Score.new(average, false, meets_student_threshold, false)
        end

        def sufficient_responses(averages:, number_of_responses:)
          total_questions = averages.count
          average_num_of_responses = number_of_responses.to_f / total_questions
          meets_student_threshold = average_num_of_responses >= 10
        end

        def bubble_up_averages(responses:)
          measure.student_scales.map do |scale|
            scale.survey_items.map do |survey_item|
              responses[survey_item.id]
            end.remove_blanks.average
          end.remove_blanks
        end
      end
    end
  end
end
