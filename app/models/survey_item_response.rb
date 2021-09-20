class SurveyItemResponse < ActiveRecord::Base
  belongs_to :school
  belongs_to :survey_item
end
