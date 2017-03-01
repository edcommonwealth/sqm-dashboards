class School < ApplicationRecord
  belongs_to :district
  has_many :recipients

  validates :name, presence: true

end
