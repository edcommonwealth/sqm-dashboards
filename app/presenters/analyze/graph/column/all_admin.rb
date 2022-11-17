# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllAdmin < GroupedBarColumnPresenter
        def label
          'All Admin'
        end

        def basis
          'student'
        end

        def show_irrelevancy_message?
          # !measure.includes_admin_data_items?
          false
        end

        def show_insufficient_data_message?
          # academic_years.any? do |year|
          #   measure.sufficient_admin_data?(school:, academic_year: year)
          # end
          false
        end

        def score(year_index)
          measure.admin_score(school:, academic_year: academic_years[year_index])
          # Score.new(average: 3)
        end
      end
    end
  end
end
