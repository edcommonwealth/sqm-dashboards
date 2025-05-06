# frozen_string_literal: true

module Analyze
  module Graph
    module Column
      class AllStudent
        def label
          ["All", "Students"]
        end

        def basis
          "student surveys"
        end

        def insufficiency_message
          ["survey response", "rate below 25%"]
        end

        def show_irrelevancy_message?(construct:)
          !construct.includes_student_survey_items?
        end

        def show_insufficient_data_message?(construct:, school:, academic_years:)
          scores = academic_years.map do |academic_year|
            construct.student_score(school:, academic_year:)
          end

          scores.none? { |score| score.meets_student_threshold? }
        end

        def score(construct:, school:, academic_year:)
          construct.student_score(school:, academic_year:)
        end

        def type
          :student
        end

        def n_size(construct:, school:, academic_year:)
          grades = Respondent.by_school_and_year(school:, academic_year:)&.enrollment_by_grade&.keys
          SurveyItemResponse.where(survey_item: construct.student_survey_items, school:, grade: grades,
                                   academic_year:).select(:response_id).distinct.count
        end
      end
    end
  end
end
