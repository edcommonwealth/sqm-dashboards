# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class ColumnBase
        def label
          raise NotImplementedError
        end

        def basis
          raise NotImplementedError
        end

        def show_irrelevancy_message?(measure:)
          raise NotImplementedError
        end

        def show_insufficient_data_message?(measure:, school:, academic_years:)
          raise NotImplementedError
        end

        def insufficiency_message
          raise NotImplementedError
        end

        def score(measure:, school:, academic_year:)
          raise NotImplementedError
        end

        def type
          raise NotImplementedError
        end

        def n_size(measure:, school:, academic_year:)
          raise NotImplementedError
        end

        def bubble_up_averages(measure:, averages:)
          measure.student_scales.map do |scale|
            scale.survey_items.map do |survey_item|
              averages[survey_item]
            end.remove_blanks.average
          end.remove_blanks.average
        end

        def grades(school:, academic_year:)
          Respondent.by_school_and_year(school:, academic_year:)&.enrollment_by_grade&.keys
        end
      end
    end
  end
end
