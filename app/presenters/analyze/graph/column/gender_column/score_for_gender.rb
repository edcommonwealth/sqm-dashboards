module Analyze
  module Graph
    module Column
      module GenderColumn
        module ScoreForGender
          def score(year_index)
            academic_year = academic_years[year_index]
            meets_student_threshold = sufficient_student_responses?(academic_year:)
            return Score::NIL_SCORE unless meets_student_threshold

            averages = SurveyItemResponse.averages_for_gender(measure.student_survey_items, school, academic_year,
                                                              gender)
            average = bubble_up_averages(averages:).round(2)

            Score.new(average:,
                      meets_teacher_threshold: false,
                      meets_student_threshold:,
                      meets_admin_data_threshold: false)
          end

          def bubble_up_averages(averages:)
            measure.student_scales.map do |scale|
              scale.survey_items.map do |survey_item|
                averages[survey_item]
              end.remove_blanks.average
            end.remove_blanks.average
          end

          def sufficient_student_responses?(academic_year:)
            return false unless measure.subcategory.response_rate(school:, academic_year:).meets_student_threshold?

            yearly_counts = SurveyItemResponse.where(school:, academic_year:,
                                                     gender:, survey_item: measure.student_survey_items).group(:gender).select(:response_id).distinct(:response_id).count
            yearly_counts.any? do |count|
              count[1] >= 10
            end
          end
        end
      end
    end
  end
end
