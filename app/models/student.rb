class Student < ApplicationRecord
  has_many :survey_item_responses
  has_many :student_races
  has_many :races, through: :student_races

  encrypts :lasid, deterministic: true
end
