# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Hispanic < GroupedBarColumnPresenter
        include Analyze::Graph::Column::RaceScore
        def label
          'Hispanic'
        end

        def basis
          'student'
        end

        def show_irrelevancy_message?
          # !measure.includes_student_survey_items?
          false
        end

        def show_insufficient_data_message?
          false
        end

        def score(year_index)
          race_score(measure:, school:, academic_year: academic_years[year_index], race:)
        end

        def race
          Race.find_by_qualtrics_code 4
        end
      end
    end
  end
end
