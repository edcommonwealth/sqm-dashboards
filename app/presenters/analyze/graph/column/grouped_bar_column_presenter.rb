# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class GroupedBarColumnPresenter
        include AnalyzeHelper

        attr_reader :measure_name, :measure_id, :category, :position, :measure, :school, :academic_years,
                    :number_of_columns, :config

        def initialize(measure:, school:, academic_years:, position:, number_of_columns:, config:)
          @measure = measure
          @measure_name = @measure.name
          @measure_id = @measure.measure_id
          @category = @measure.subcategory.category
          @school = school
          @academic_years = academic_years
          @position = position
          @number_of_columns = number_of_columns
          @config = config
        end

        def bars
          @bars ||= academic_years.map.with_index do |academic_year, index|
            Analyze::BarPresenter.new(measure:, academic_year:,
                                      score: score(academic_year:),
                                      x_position: bar_x(index),
                                      color: bar_color(academic_year))
          end.reject(&:blank?).select { |bar| bar.score.average&.positive? }
          @bars
        end

        def label
          config.label
        end

        def show_irrelevancy_message?
          config.show_irrelevancy_message?(measure:)
        end

        def show_insufficient_data_message?
          config.show_insufficient_data_message?(measure:, school:, academic_years:)
        end

        def score(academic_year:)
          config.score(measure:, school:, academic_year:)
        end

        def n_size(academic_year:)
          config.n_size(measure:, school:, academic_year:)
        end

        def basis
          config.basis
        end

        def type
          config.type
        end

        def insufficiency_message
          config.insufficiency_message
        end

        def show_popover?
          %i[student teacher parent].include? type
        end

        def popover_content(academic_year)
          "#{n_size(academic_year:)} #{type.to_s.capitalize}s"
        end

        def column_midpoint
          zone_label_width + (grouped_chart_column_width * (position + 1)) - (grouped_chart_column_width / 2)
        end

        def bar_width
          min_bar_width(10.5 / data_sources)
        end

        def min_bar_width(number)
          min_width = 2
          number < min_width ? min_width : number
        end

        def message_x
          column_midpoint - message_width / 2
        end

        def message_y
          17
        end

        def message_width
          20
        end

        def message_height
          34
        end

        def column_end_x
          zone_label_width + (grouped_chart_column_width * (position + 1))
        end

        def column_start_x
          zone_label_width + (grouped_chart_column_width * position)
        end

        def grouped_chart_column_width
          graph_width / data_sources
        end

        def bar_label_height
          (100 - ((100 - analyze_graph_height) / 2))
        end

        def data_sources
          number_of_columns
        end

        def grades
          Respondent.by_school_and_year(school:, academic_year: academic_years)&.enrollment_by_grade&.keys
        end

        private

        def bar_color(year)
          @available_academic_years ||= AcademicYear.order(:range).all
          colors[@available_academic_years.find_index(year)]
        end

        def bar_x(index)
          column_start_x + (index * bar_width * 1.2) +
            ((column_end_x - column_start_x) - (academic_years.size * bar_width * 1.2)) / 2
        end
      end
    end
  end
end
