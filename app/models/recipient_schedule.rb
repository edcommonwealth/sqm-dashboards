class RecipientSchedule < ApplicationRecord

  belongs_to :recipient
  belongs_to :schedule
  has_many :attempts

  scope :ready, -> { where('next_attempt_at <= ?', Time.new) }

  def next_question
    upcoming = upcoming_question_ids.split(/,/)
    Question.where(id: upcoming.first).first
  end

  def attempt_question(question: next_question)
    attempt = recipient.attempts.create(
      schedule: schedule,
      recipient_schedule: self,
      question: question
    )

    if attempt.send_message
      upcoming = upcoming_question_ids.split(/,/)[1..-1].join(',')
      attempted = (attempted_question_ids.split(/,/) + [question.id]).join(',')
      update_attributes(
        upcoming_question_ids: upcoming,
        attempted_question_ids: attempted,
        last_attempt_at: attempt.sent_at,
        next_attempt_at: attempt.sent_at + (60 * 60 * schedule.frequency_hours)
      )
    end
    return attempt
  end
end
