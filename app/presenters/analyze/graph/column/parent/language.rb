# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module Parent
        class Language < ColumnBase
          attr_reader :language, :label

          def initialize(languages:, label:, show_irrelevancy_message:)
            @language = languages
            @label = label
            @show_irrelevancy_message = show_irrelevancy_message
          end

          def basis
            "parent surveys"
          end

          def show_irrelevancy_message?(construct:)
            false
          end

          def show_insufficient_data_message?(construct:, school:, academic_years:)
            false
          end

          def type
            :parent
          end

          def n_size(construct:, school:, academic_year:)
            SurveyItemResponse.joins([parent: :languages]).where(languages: { designation: designations }, survey_item: construct.parent_survey_items, school:, academic_year:).select(:parent_id).distinct.count
          end

          def score(construct:, school:, academic_year:)
            return Score::NIL_SCORE if n_size(construct:, school:, academic_year:) < 10

            averages = SurveyItemResponse.averages_for_language(construct.parent_survey_items, school, academic_year,
                                                           designations)
            average = bubble_up_averages(construct:, averages:).round(2)
            Score.new(average:,
                      meets_teacher_threshold: false,
                      meets_student_threshold: true,
                      meets_admin_data_threshold: false)
          end

          def designations
            language.map(&:designation)
          end

          def bubble_up_averages(construct:, averages:)
            name = construct.class.name.downcase
            send("#{name}_bubble_up_averages", construct:, averages:)
          end

          def measure_bubble_up_averages(construct:, averages:)
            construct.parent_scales.map do |scale|
              scale_bubble_up_averages(construct: scale, averages:)
            end.remove_blanks.average
          end

          def scale_bubble_up_averages(construct:, averages:)
            construct.survey_items.map do |survey_item|
              averages[survey_item]
            end.remove_blanks.average
          end

          def show_irrelevancy_message?(construct:)
            return false if @show_irrelevancy_message == false

            construct.survey_items.parent_survey_items.count.zero?
          end
        end
      end
    end
  end
end
