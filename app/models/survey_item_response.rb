class SurveyItemResponse < ActiveRecord::Base
  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item
end
