# frozen_string_literal: true

class Respondent < ApplicationRecord
  belongs_to :school
  belongs_to :academic_year
end
