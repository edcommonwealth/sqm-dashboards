module Analyze
  module Graph
    module Column
      class AllData < GroupedBarColumnPresenter
        def label
          %w[All Data]
        end

        def show_irrelevancy_message?
          false
        end

        def show_insufficient_data_message?
          scores = academic_years.map do |year|
            measure.score(school:, academic_year: year)
          end

          scores.none? do |score|
            score.meets_teacher_threshold? || score.meets_student_threshold? || score.meets_admin_data_threshold?
          end
        end

        def score(academic_year)
          measure.score(school:, academic_year:) || 0
        end

        def type
          :all_data
        end

        def basis
          "student surveys"
        end

        def n_size(academic_year)
          SurveyItemResponse.where(survey_item: measure.student_survey_items, school:, grade: grades,
                                   academic_year:).select(:response_id).distinct.count
        end
      end
    end
  end
end