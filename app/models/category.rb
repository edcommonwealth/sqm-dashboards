# frozen_string_literal: true

class Category < ActiveRecord::Base
  include FriendlyId
  friendly_id :name, use: [:slugged]

  scope :sorted, -> { order(:sort_index) }

  has_many :subcategories
  has_many :measures, through: :subcategories
  has_many :admin_data_items, through: :measures
  has_many :scales, through: :subcategories
  has_many :survey_items, through: :scales
end
