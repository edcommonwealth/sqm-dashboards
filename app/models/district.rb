# frozen_string_literal: true

class District < ApplicationRecord
  has_many :schools

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }

  include FriendlyId

  friendly_id :name, use: [:slugged]

  before_save do
    self.slug ||= name.parameterize
  end

  def self.boston
    @@boston ||= District.find_by_name('Boston')
  end
end
