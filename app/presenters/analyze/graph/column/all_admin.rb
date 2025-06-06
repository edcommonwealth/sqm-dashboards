# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllAdmin
        def label
          %w[School Data]
        end

        def basis
          "school data"
        end

        def show_irrelevancy_message?(construct:)
          !construct.includes_admin_data_items?
        end

        def show_insufficient_data_message?(construct:, school:, academic_years:)
          !academic_years.any? do |year|
            construct.sufficient_admin_data?(school:, academic_year: year)
          end
        end

        def insufficiency_message
          ["data not", "available"]
        end

        def score(construct:, school:, academic_year:)
          construct.admin_score(school:, academic_year:)
        end

        def type
          :admin
        end
      end
    end
  end
end
