class RecipientSchedule < ApplicationRecord

  belongs_to :recipient
  belongs_to :schedule
  has_many :attempts

  def next_question
    upcoming = upcoming_question_ids.split(/,/)
    Question.where(id: upcoming.first).first
  end

  def make_attempt(question: next_question)
    sent_at = Time.new
    recipient.attempts.create(
      schedule: schedule,
      recipient_schedule: self,
      question: question,
      sent_at: sent_at
    )

    upcoming = upcoming_question_ids.split(/,/)[1..-1].join(',')
    attempted = (attempted_question_ids.split(/,/) + [question.id]).join(',')
    update_attributes(
      upcoming_question_ids: upcoming,
      attempted_question_ids: attempted,
      last_attempt_at: sent_at
    )
  end
end
