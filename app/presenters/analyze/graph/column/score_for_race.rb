module Analyze
  module Graph
    module Column
      module ScoreForRace
        def score(year_index)
          academic_year = academic_year_for_year_index(year_index)
          rate = response_rate(school:, academic_year:, measure:)
          return Score::NIL_SCORE unless rate.meets_student_threshold

          survey_items = measure.student_survey_items

          averages = grouped_responses(school:, academic_year:, survey_items:, race:)
          meets_student_threshold = sufficient_responses(school:, academic_year:, race:)
          scorify(responses: averages, meets_student_threshold:, measure:)
        end

        def grouped_responses(school:, academic_year:, survey_items:, race:)
          @grouped_responses ||= Hash.new do |memo, (school, academic_year, survey_items, race)|
            memo[[school, academic_year, survey_items, race]] =
              SurveyItemResponse.joins("JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id").where(
                school:, academic_year:, grade: school.grades(academic_year:)
              ).where("student_races.race_id": race.id).group(:survey_item_id).having("count(*) >= 10").average(:likert_score)
          end

          @grouped_responses[[school, academic_year, survey_items, race]]
        end

        def response_rate(school:, academic_year:, measure:)
          subcategory = measure.subcategory
          @response_rate ||= Hash.new do |memo, (school, academic_year, subcategory)|
            memo[[school, academic_year, subcategory]] = subcategory.response_rate(school:, academic_year:)
          end

          @response_rate[[school, academic_year, subcategory]]
        end

        def scorify(responses:, meets_student_threshold:, measure:)
          averages = bubble_up_averages(responses:, measure:)
          average = averages.average.round(2)

          average = 0 unless meets_student_threshold

          Score.new(average:, meets_teacher_threshold: false, meets_student_threshold:,
                    meets_admin_data_threshold: false)
        end

        def sufficient_responses(school:, academic_year:, race:)
          @sufficient_responses ||= Hash.new do |memo, (school, academic_year, race)|
            number_of_students_for_a_racial_group = SurveyItemResponse.joins("JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id").where(
              school:, academic_year:
            ).where("student_races.race_id": race.id).distinct.pluck(:student_id).count
            memo[[school, academic_year, race]] = number_of_students_for_a_racial_group >= 10
          end
          @sufficient_responses[[school, academic_year, race]]
        end

        def bubble_up_averages(responses:, measure:)
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
