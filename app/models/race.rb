class Race < ApplicationRecord
  include FriendlyId
  has_many :student_races
  has_many :students, through: :student_races
  friendly_id :designation, use: [:slugged]
end
