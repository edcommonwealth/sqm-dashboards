# frozen_string_literal: true

class ResponseRate < ApplicationRecord
  belongs_to :subcategory
  belongs_to :school
  belongs_to :academic_year
end
