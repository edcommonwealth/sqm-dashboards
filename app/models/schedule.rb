class Schedule < ApplicationRecord
  belongs_to :school
  belongs_to :recipient_list
  belongs_to :question_list

  validates :name, presence: true
  validates :recipient_list, presence: true
  validates :question_list, presence: true


end
