# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class Ell < ColumnBase
        attr_reader :ell

        def initialize(ell:)
          @ell = ell
        end

        def label
          ["#{ell.designation}"]
        end

        def basis
          "student"
        end

        def show_irrelevancy_message?(construct:)
          false
        end

        def show_insufficient_data_message?(construct:, school:, academic_years:)
          false
        end

        def type
          :student
        end

        def n_size(construct:, school:, academic_year:)
          SurveyItemResponse.where(ell:, survey_item: construct.student_survey_items, school:, grade: grades(school:, academic_year:),
                                   academic_year:).select(:response_id).distinct.count
        end

        def score(construct:, school:, academic_year:)
          meets_student_threshold = sufficient_student_responses?(construct:, school:, academic_year:)
          return Score::NIL_SCORE unless meets_student_threshold

          averages = SurveyItemResponse.averages_for_ell(construct.student_survey_items, school, academic_year,
                                                         ell)
          average = bubble_up_averages(construct:, averages:).round(2)

          Score.new(average:,
                    meets_teacher_threshold: false,
                    meets_student_threshold:,
                    meets_admin_data_threshold: false)
        end

        def sufficient_student_responses?(construct:, school:, academic_year:)
          return false unless construct.subcategory.response_rate(school:, academic_year:).meets_student_threshold?

          yearly_counts = SurveyItemResponse.where(school:, academic_year:,
                                                   ell:, survey_item: construct.student_survey_items).group(:ell).select(:response_id).distinct(:response_id).count
          yearly_counts.any? do |count|
            count[1] >= 10
          end
        end
      end
    end
  end
end
