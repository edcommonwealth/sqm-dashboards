# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllSurveyData
        def label
          %w[Survey Data]
        end

        def basis
          "survey data"
        end

        def show_irrelevancy_message?(construct:)
          !construct.includes_teacher_survey_items? || !construct.includes_student_survey_items? || !construct.includes_parent_survey_items?
        end

        def show_insufficient_data_message?(construct:, school:, academic_years:)
          scores = academic_years.map do |academic_year|
            score(construct:, school:, academic_year:)
          end

          scores.all? { |score| !score.meets_student_threshold? && !score.meets_teacher_threshold? }
        end

        def insufficiency_message
          ["survey response", "rate below 25%"]
        end

        def score(construct:, school:, academic_year:)
          teacher_score = construct.teacher_score(school:, academic_year:)
          student_score = construct.student_score(school:, academic_year:)

          averages = []
          averages << student_score.average unless student_score.average.nil?
          averages << teacher_score.average unless teacher_score.average.nil?
          average = averages.average if averages.length > 0
          combined_score = Score.new(average:, meets_student_threshold: student_score.meets_student_threshold,
                                     meets_teacher_threshold: teacher_score.meets_teacher_threshold)
        end

        def type
          :all_survey_data
        end
      end
    end
  end
end
