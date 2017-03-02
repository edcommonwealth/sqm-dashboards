class RecipientList < ApplicationRecord
  belongs_to :school

  validates :name, presence: true
  validates :recipient_ids, presence: true
end
