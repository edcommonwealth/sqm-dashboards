# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Black < GroupedBarColumnPresenter
        include Analyze::Graph::Column::RaceScore
        def label
          'Black or African American'
        end

        def basis
          'student'
        end

        def show_irrelevancy_message?
          !measure.includes_student_survey_items?
        end

        def show_insufficient_data_message?
          false
        end

        def score(year_index)
          race_score(measure:, school:, academic_year: academic_years[year_index], race:)
        end

        def race
          Race.find_by_qualtrics_code 3
        end
      end
    end
  end
end