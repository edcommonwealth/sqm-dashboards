# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllTeacher < GroupedBarColumnPresenter
        def label
          %w[All Teachers]
        end

        def basis
          "teacher surveys"
        end

        def show_irrelevancy_message?
          !measure.includes_teacher_survey_items?
        end

        def show_insufficient_data_message?
          scores = academic_years.map do |year|
            measure.score(school:, academic_year: year)
          end

          scores.all? { |score| !score.meets_teacher_threshold? }
        end

        def score(academic_year)
          measure.teacher_score(school:, academic_year:)
        end

        def type
          :teacher
        end

        def n_size(academic_year)
          SurveyItemResponse.where(survey_item: measure.teacher_survey_items, school:,
                                   academic_year:).pluck(:response_id).uniq.count
        end
      end
    end
  end
end
