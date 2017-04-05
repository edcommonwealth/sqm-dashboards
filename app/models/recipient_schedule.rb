class RecipientSchedule < ApplicationRecord

  belongs_to :recipient
  belongs_to :schedule
  has_many :attempts

  validates_associated :recipient
  validates_associated :schedule
  validates :next_attempt_at, presence: true

  scope :ready, -> { where('next_attempt_at <= ?', Time.new) }
  scope :for, -> (recipient_or_recipient_id) {
    id = recipient_or_recipient_id.is_a?(Recipient) ?
      recipient_or_recipient_id.id :
      recipient_or_recipient_id
    where(recipient_id: id)
  }

  def next_question
    upcoming = upcoming_question_ids.split(/,/)
    Question.where(id: upcoming.first).first
  end

  def attempt_question(send_message: true, question: next_question)
    return if recipient.opted_out?
    attempt = recipient.attempts.create(
      schedule: schedule,
      recipient_schedule: self,
      question: question
    )

    if send_message && attempt.send_message
      return if upcoming_question_ids.blank?
      upcoming = upcoming_question_ids.split(/,/)[1..-1].join(',')
      attempted = ((attempted_question_ids.try(:split, /,/) || []) + [question.id]).join(',')
      update_attributes(
        upcoming_question_ids: upcoming,
        attempted_question_ids: attempted,
        last_attempt_at: attempt.sent_at,
        next_attempt_at: attempt.sent_at + (60 * 60 * schedule.frequency_hours)
      )
    end
    return attempt
  end

  def self.create_for_recipient(recipient_or_recipient_id, schedule, next_attempt_at=Time.new)
    question_ids = schedule.question_list.question_ids.split(/,/)
    question_ids = question_ids.shuffle if schedule.random?

    recipient_id = recipient_or_recipient_id.is_a?(Recipient) ?
      recipient_or_recipient_id.id :
      recipient_or_recipient_id

    schedule.recipient_schedules.create(
      recipient_id: recipient_id,
      upcoming_question_ids: question_ids.join(','),
      next_attempt_at: next_attempt_at
    )
  end


end
