# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      module Parent
        class Base
          def label
            raise NotImplementedError
          end

          def basis
            raise NotImplementedError
          end

          def show_irrelevancy_message?(construct:)
            raise NotImplementedError
          end

          def show_insufficient_data_message?(construct:, school:, academic_years:)
            raise NotImplementedError
          end

          def insufficiency_message
            raise NotImplementedError
          end

          def score(construct:, school:, academic_year:)
            raise NotImplementedError
          end

          def type
            raise NotImplementedError
          end

          def n_size(construct:, school:, academic_year:)
            raise NotImplementedError
          end

          def show_insufficient_data_message?(construct:, school:, academic_years:)
            false
          end

          def basis
            "parent surveys"
          end

          def type
            :parent
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
