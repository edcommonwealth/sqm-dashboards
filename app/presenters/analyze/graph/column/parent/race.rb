# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module Parent
        class Race < Base
          attr_reader :race, :label

          def initialize(races:, label:, show_irrelevancy_message:)
            @race = races
            @label = label
            @show_irrelevancy_message = show_irrelevancy_message
          end

          def n_size(construct:, school:, academic_year:)
            designation = if race.instance_of? ::Race
                            race.designation
                          else
                            race.map(&:designation)
                          end
            SurveyItemResponse.joins([parent: :races]).where(races: { designation: }, survey_item: construct.parent_survey_items, school:, academic_year:).select(:parent_id).distinct.count
          end

          def score(construct:, school:, academic_year:)
            return Score::NIL_SCORE if n_size(construct:, school:, academic_year:) < 10

            averages = SurveyItemResponse.averages_for_parent_race(construct.parent_survey_items, school, academic_year, race)
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
