class District < ApplicationRecord
  has_many :schools

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }

end
