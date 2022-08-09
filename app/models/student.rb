class Student < ApplicationRecord
  has_many :survey_item_responses
  has_many :student_races
  has_and_belongs_to_many :races, join_table: :student_races

  encrypts :lasid, deterministic: true
end
