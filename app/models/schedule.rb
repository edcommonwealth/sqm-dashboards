class Schedule < ApplicationRecord
  belongs_to :school
  belongs_to :recipient_list
  belongs_to :question_list
  has_many :recipient_schedules

  validates :name, presence: true
  validates :recipient_list, presence: true
  validates :question_list, presence: true

  before_validation :set_start_date
  after_create :create_recipient_schedules

  scope :active, -> {
    where(active: true).where("start_date <= ? and end_date > ?", Date.today, Date.today)
  }

  private

    def set_start_date
      return if start_date.present?
      self.start_date = Date.today
    end

    def create_recipient_schedules
      recipient_list.recipients.each do |recipient|
        RecipientSchedule.create_for_recipient(recipient, self)
      end
    end

end
