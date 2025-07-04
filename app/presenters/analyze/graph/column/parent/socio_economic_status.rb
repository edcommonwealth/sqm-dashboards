# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module Parent
        class SocioEconomicStatus < Base
          attr_reader :socio_economic_status, :label

          def initialize(socio_economic_status:, label:, show_irrelevancy_message: false)
            @socio_economic_status = socio_economic_status
            @label = label
            @show_irrelevancy_message = show_irrelevancy_message
          end

          def n_size(construct:, school:, academic_year:)
            SurveyItemResponse.joins(:parent).where(parent: { socio_economic_status: }, survey_item: construct.parent_survey_items, school:, academic_year:).select(:parent_id).distinct.count
          end

          def score(construct:, school:, academic_year:)
            return Score::NIL_SCORE if n_size(construct:, school:, academic_year:) < 10

            averages = SurveyItemResponse.averages_for_socio_economic_status(construct.parent_survey_items, school, academic_year,
                                                           socio_economic_status)
            average = bubble_up_averages(construct:, averages:).round(2)
            Score.new(average:,
                      meets_teacher_threshold: false,
                      meets_student_threshold: true,
                      meets_admin_data_threshold: false)
          end

          def designations
            language.map(&:designation)
          end
        end
      end
    end
  end
end
