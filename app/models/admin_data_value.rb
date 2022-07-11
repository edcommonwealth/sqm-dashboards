# frozen_string_literal: true

class AdminDataValue < ApplicationRecord
  belongs_to :school
  belongs_to :admin_data_item
  belongs_to :academic_year
end
