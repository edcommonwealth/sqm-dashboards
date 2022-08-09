class RaceScore < ApplicationRecord
  belongs_to :measure
  belongs_to :school
  belongs_to :academic_year
  belongs_to :race
end
