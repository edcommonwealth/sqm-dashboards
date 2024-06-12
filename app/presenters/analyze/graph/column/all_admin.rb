# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllAdmin < GroupedBarColumnPresenter
        def label
          %w[School Data]
        end

        def basis
          "school data"
        end

        def show_irrelevancy_message?
          !measure.includes_admin_data_items?
        end

        def show_insufficient_data_message?
          !academic_years.any? do |year|
            measure.sufficient_admin_data?(school:, academic_year: year)
          end
        end

        def insufficiency_message
          ["data not", "available"]
        end

        def score(academic_year)
          measure.admin_score(school:, academic_year:)
        end

        def type
          :admin
        end
      end
    end
  end
end
