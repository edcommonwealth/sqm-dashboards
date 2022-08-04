# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AmericanIndian < GroupedBarColumnPresenter
        include Analyze::Graph::Column::RaceScore
        def label
          # TODO: offset labels so they don't overlap
          'American Indian'
        end

        def basis
          'student'
        end

        def show_irrelevancy_message?
          !measure.includes_student_survey_items?
        end

        def show_insufficient_data_message?
          # TODO: implement this logic.  Resize messages so they are bound to their column
          false
        end

        def score(year_index)
          # TODO: make sure the score calculation bubble up instead of just average
          race_score(measure:, school:, academic_year: academic_years[year_index], race:)
        end

        def race
          Race.find_by_qualtrics_code 1
        end
      end
    end
  end
end
