module Analyze
  module Graph
    module Column
      module Grade
        module ScoreForGrade
          def score(year_index)
            academic_year = academic_years[year_index]
            averages = SurveyItemResponse.averages_for_grade(measure.student_survey_items, school,
                                                             academic_year, grade)
            average = bubble_up_averages(averages:).round(2)

            Score.new(average:,
                      meets_teacher_threshold: false,
                      meets_student_threshold: sufficient_student_responses?(academic_year:),
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
            measure.subcategory.response_rate(school:, academic_year:).meets_student_threshold
          end
        end
      end
    end
  end
end
