# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Multiracial < GroupedBarColumnPresenter
        include Analyze::Graph::Column::ScoreForRace
        def label
          'Multiracial'
        end

        def basis
          'student'
        end

        def show_irrelevancy_message?
          false
        end

        def show_insufficient_data_message?
          false
        end

        def race
          Race.find_by_qualtrics_code 100
        end
      end
    end
  end
end