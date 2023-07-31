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
          scores = academic_years.map do |year|
            measure.score(school:, academic_year: year)
          end

          scores.all? { |score| !score.meets_student_threshold? }
        end

        def score(year_index)
          measure.student_score(school:, academic_year: academic_years[year_index])
        end

        def type
          :student
        end
      end
    end
  end
end
