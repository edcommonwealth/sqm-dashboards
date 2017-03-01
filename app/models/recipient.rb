class Recipient < ApplicationRecord
  belongs_to :school
  validates_associated :school

  validates :name, presence: true

end
