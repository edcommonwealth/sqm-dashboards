# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module Parent
        class Gender < Base
          attr_reader :genders, :label

          def initialize(genders:, label:, show_irrelevancy_message:)
            @genders = genders
            @label = label
            @show_irrelevancy_message = show_irrelevancy_message
          end

          def n_size(construct:, school:, academic_year:)
            id = if genders.instance_of? ::Gender
                   genders.id
                 else
                   genders.map(&:id)
                 end
            SurveyItemResponse.joins([parent: :genders]).where(genders: { id: }, survey_item: construct.parent_survey_items, school:, academic_year:).select(:parent_id).distinct.count
          end

          def score(construct:, school:, academic_year:)
            return Score::NIL_SCORE if n_size(construct:, school:, academic_year:) < 10

            averages = SurveyItemResponse.averages_for_parent_gender(construct.parent_survey_items, school, academic_year, genders)
            average = bubble_up_averages(construct:, averages:).round(2)
            Score.new(average:,
                      meets_teacher_threshold: false,
                      meets_student_threshold: true,
                      meets_admin_data_threshold: false)
          end
        end
      end
    end
  end
end
