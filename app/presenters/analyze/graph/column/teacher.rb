# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Teacher < GroupedBarColumnPresenter
        def label
          'All Teachers'
        end

        def basis
          'teacher'
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

        def score(year_index)
          measure.teacher_score(school:, academic_year: academic_years[year_index])
        end
      end
    end
  end
end