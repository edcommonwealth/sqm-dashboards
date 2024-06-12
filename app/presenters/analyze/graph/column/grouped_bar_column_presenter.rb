# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class GroupedBarColumnPresenter
        include AnalyzeHelper

        attr_reader :measure_name, :measure_id, :category, :position, :measure, :school, :academic_years,
                    :number_of_columns

        def initialize(measure:, school:, academic_years:, position:, number_of_columns:)
          @measure = measure
          @measure_name = @measure.name
          @measure_id = @measure.measure_id
          @category = @measure.subcategory.category
          @school = school
          @academic_years = academic_years
          @position = position
          @number_of_columns = number_of_columns
        end

        def bars
          @bars ||= yearly_scores.map.each_with_index do |yearly_score, index|
            year = yearly_score.year
            Analyze::BarPresenter.new(measure:, academic_year: year,
                                      score: yearly_score.score,
                                      x_position: bar_x(index),
                                      color: bar_color(year))
          end.reject(&:blank?).select { |bar| bar.score.average&.positive? }
        end

        def label
          raise NotImplementedError
        end

        def basis
          ""
        end

        def show_irrelevancy_message?
          raise NotImplementedError
        end

        def show_insufficient_data_message?
          raise NotImplementedError
        end

        def score(academic_year)
          raise NotImplementedError
        end

        def basis
          "student surveys"
        end

        def type
          raise NotImplementedError
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

        def show_popover?
          %i[student teacher].include? type
        end

        def n_size(year_index)
          SurveyItemResponse.where(survey_item: measure.student_survey_items, school:, grade: grades,
                                   academic_year: academic_years[year_index]).select(:response_id).distinct.count
        end

        def popover_content(year_index)
          "#{n_size(year_index)} #{type.to_s.capitalize}s"
        end

        def insufficiency_message
          ["survey response", "rate below 25%"]
        end

        def grades
          Respondent.by_school_and_year(school:, academic_year: academic_years)&.enrollment_by_grade&.keys
        end

        private

        YearlyScore = Struct.new(:year, :score)
        def yearly_scores
          yearly_scores = academic_years.each.map do |year|
            YearlyScore.new(year, score(year))
          end.reject { |year| year.score.nil? || year.score.blank? }
        end

        def bar_color(year)
          @available_academic_years ||= AcademicYear.order(:range).all
          colors[@available_academic_years.find_index(year)]
        end

        def bar_x(index)
          column_start_x + (index * bar_width * 1.2) +
            ((column_end_x - column_start_x) - (yearly_scores.size * bar_width * 1.2)) / 2
        end
      end
    end
  end
end
