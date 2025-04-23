# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Language < ColumnBase
        attr_reader :language, :label

        def initialize(languages:, label:)
          @language = languages
          @label = label
        end

        def basis
          "parent surveys"
        end

        def show_irrelevancy_message?(measure:)
          false
        end

        def show_insufficient_data_message?(measure:, school:, academic_years:)
          false
        end

        def type
          :parent
        end

        def n_size(measure:, school:, academic_year:)
          SurveyItemResponse.joins([parent: :languages]).where(languages: { designation: designations }, survey_item: measure.parent_survey_items, school:, academic_year:).select(:parent_id).distinct.count
        end

        def score(measure:, school:, academic_year:)
          averages = SurveyItemResponse.averages_for_language(measure.parent_survey_items, school, academic_year,
                                                         designations)
          average = bubble_up_averages(measure:, averages:).round(2)
          Score.new(average:,
                    meets_teacher_threshold: false,
                    meets_student_threshold: true,
                    meets_admin_data_threshold: false)
        end

        def designations
          language.map(&:designation)
        end

        def bubble_up_averages(measure:, averages:)
          measure.parent_scales.map do |scale|
            scale.survey_items.map do |survey_item|
              averages[survey_item]
            end.remove_blanks.average
          end.remove_blanks.average
        end
      end
    end
  end
end
