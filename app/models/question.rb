class Question < ApplicationRecord
  belongs_to :category

  validates :text, presence: true
  validates :option1, presence: true
  validates :option2, presence: true
  validates :option3, presence: true
  validates :option4, presence: true
  validates :option5, presence: true

  def options
    [option1, option2, option3, option4, option5].map(&:downcase).map(&:strip)
  end

  def option_index(answer)
    options.index(answer.downcase.strip)
  end
end
