# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllStudent < GroupedBarColumnPresenter
        def label
          %w[All Students]
        end

        def show_irrelevancy_message?
          !measure.includes_student_survey_items?
        end

        def show_insufficient_data_message?
          scores = academic_years.map do |academic_year|
            measure.student_score(school:, academic_year:)
          end

          scores.none? { |score| score.meets_student_threshold? }
        end

        def score(academic_year)
          measure.student_score(school:, academic_year:)
        end

        def type
          :student
        end

        def n_size(academic_year)
          SurveyItemResponse.where(survey_item: measure.student_survey_items, school:, grade: grades,
                                   academic_year:).select(:response_id).distinct.count
        end
      end
    end
  end
end
