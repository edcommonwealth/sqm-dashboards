class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 2
  STUDENT_RESPONSE_THRESHOLD = 2

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item
end
