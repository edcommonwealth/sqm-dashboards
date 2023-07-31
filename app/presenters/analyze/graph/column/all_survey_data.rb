# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllSurveyData < GroupedBarColumnPresenter
        def label
          %w[Survey Data]
        end

        def show_irrelevancy_message?
          false
        end

        def show_insufficient_data_message?
          scores = academic_years.map do |year|
            combined_score(school:, academic_year: year)
          end

          scores.all? { |score| !score.meets_student_threshold? && !score.meets_teacher_threshold? }
        end

        def score(year_index)
          combined_score(school:, academic_year: academic_years[year_index])
        end

        def type
          :all_survey_data
        end

        private

        def combined_score(school:, academic_year:)
          teacher_score = measure.teacher_score(school:, academic_year:)
          student_score = measure.student_score(school:, academic_year:)

          averages = []
          averages << student_score.average unless student_score.average.nil?
          averages << teacher_score.average unless teacher_score.average.nil?
          average = averages.average if averages.length > 0
          combined_score = Score.new(average:, meets_student_threshold: student_score.meets_student_threshold,
                                     meets_teacher_threshold: teacher_score.meets_teacher_threshold)
        end
      end
    end
  end
end
