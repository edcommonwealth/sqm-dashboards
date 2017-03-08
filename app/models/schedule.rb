class Schedule < ApplicationRecord
  belongs_to :school
  belongs_to :recipient_list
  belongs_to :question_list
  has_many :recipient_schedules

  validates :name, presence: true
  validates :recipient_list, presence: true
  validates :question_list, presence: true

  scope :active, -> { where(active: true).where("start_date <= ? and end_date > ?", Date.today, Date.today) }

end
