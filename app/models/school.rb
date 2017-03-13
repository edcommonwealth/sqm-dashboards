class School < ApplicationRecord
  has_many :schedules
  has_many :recipient_lists
  belongs_to :district
  has_many :recipients
  has_many :school_categories

  validates :name, presence: true

end
