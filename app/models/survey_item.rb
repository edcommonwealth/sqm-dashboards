class SurveyItem < ActiveRecord::Base
  belongs_to :measure
  has_many :survey_item_responses
end
