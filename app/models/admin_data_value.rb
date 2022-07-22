# frozen_string_literal: true

class AdminDataValue < ApplicationRecord
  belongs_to :school
  belongs_to :admin_data_item
  belongs_to :academic_year
  validates :likert_score, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
end
