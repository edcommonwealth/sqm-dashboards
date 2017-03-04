class Question < ApplicationRecord
  belongs_to :category

  validates :text, presence: true
  validates :option1, presence: true
  validates :option2, presence: true
  validates :option3, presence: true
  validates :option4, presence: true
  validates :option5, presence: true

end
