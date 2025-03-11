# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Race < ColumnBase
        attr_reader :race

        def initialize(race:)
          @race = race
        end

        def label
          tmp = race.designation.split("or").first
          tmp.split(" ", 2)
        end

        def basis
          "student surveys"
        end

        def show_irrelevancy_message?(measure:)
          false
        end

        def show_insufficient_data_message?(measure:, school:, academic_years:)
          false
        end

        def type
          :student
        end

        def n_size(measure:, school:, academic_year:)
          SurveyItemResponse.joins("JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id").where(
            school:, academic_year:,
            survey_item: measure.student_survey_items
          ).where("student_races.race_id": race.id).select(:response_id).distinct.count
        end

        def score(measure:, school:, academic_year:)
          meets_student_threshold = sufficient_student_responses?(measure:, school:, academic_year:)
          return Score::NIL_SCORE unless meets_student_threshold

          measure.student_survey_items

          averages = SurveyItemResponse.averages_for_race(school, academic_year, race)
          average = bubble_up_averages(measure:, averages:).round(2)

          Score.new(average:,
                    meets_teacher_threshold: false,
                    meets_student_threshold:,
                    meets_admin_data_threshold: false)
        end

        def sufficient_student_responses?(measure:, school:, academic_year:)
          return false unless measure.subcategory.response_rate(school:, academic_year:).meets_student_threshold?

          number_of_students_for_a_racial_group = SurveyItemResponse.joins("JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id").where(
            school:, academic_year:
          ).where("student_races.race_id": race.id).distinct.pluck(:student_id).count
          number_of_students_for_a_racial_group >= 10
        end
      end
    end
  end
end
