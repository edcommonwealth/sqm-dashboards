class School < ApplicationRecord
  has_many :schedules, dependent: true
  has_many :recipient_lists, dependent: true
  belongs_to :district
  has_many :recipients, dependent: true
  has_many :school_categories, dependent: true

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }

  include FriendlyId
  friendly_id :name, :use => [:slugged]

end
