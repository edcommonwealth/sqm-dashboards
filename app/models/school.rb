class School < ApplicationRecord
  has_many :recipient_lists
  belongs_to :district
  has_many :recipients

  validates :name, presence: true

end
