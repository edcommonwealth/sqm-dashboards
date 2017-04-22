class RecipientSchedule < ApplicationRecord

  belongs_to :recipient
  belongs_to :schedule
  has_many :attempts

  validates_associated :recipient
  validates_associated :schedule
  validates :next_attempt_at, presence: true

  scope :ready, -> { where('next_attempt_at <= ?', Time.new) }
  scope :for_recipient, -> (recipient_or_recipient_id) {
    id = recipient_or_recipient_id.is_a?(Recipient) ?
      recipient_or_recipient_id.id :
      recipient_or_recipient_id
    where(recipient_id: id)
  }
  scope :for_schedule, -> (schedule_or_schedule_id) {
    id = schedule_or_schedule_id.is_a?(Schedule) ?
      schedule_or_schedule_id.id :
      schedule_or_schedule_id
    where(schedule_id: id)
  }

  def next_question
    if queued_question_ids.present?
      next_question_id = queued_question_ids.split(/,/).first
    else
      next_question_id = upcoming_question_ids.split(/,/).first
    end
    Question.where(id: next_question_id).first
  end

  def upcoming_question_id_array
    upcoming_question_ids.try(:split, /,/) || []
  end

  def attempted_question_id_array
    attempted_question_ids.try(:split, /,/) || []
  end

  def queued_question_id_array
    queued_question_ids.try(:split, /,/) || []
  end

  def attempt_question_for_recipient_students(send_message: true, question: next_question)
    return if recipient.opted_out?
    return if question.nil?

    if !question.for_recipient_students?
      return attempt_question(question: question)
    end

    missing_students = []
    recipient_attempts = attempts.for_recipient(recipient).for_question(question)
    recipient.students.each do |student|
      if recipient_attempts.for_student(student).empty?
        missing_students << student
      end
    end

    attempt = recipient.attempts.create(
      schedule: schedule,
      recipient_schedule: self,
      question: question,
      student: missing_students.first
    )

    if send_message && attempt.send_message
      upcoming = upcoming_question_id_array
      queued = queued_question_id_array
      attempted = attempted_question_id_array

      if question.present?
        question_id = [question.id.to_s]
        upcoming = upcoming - question_id
        if missing_students.length > 1
          queued += question_id
        else
          attempted += question_id
          queued -= question_id
        end
      end

      update_attributes(
        upcoming_question_ids: upcoming.empty? ? nil : upcoming.join(','),
        attempted_question_ids: attempted.empty? ? nil : attempted.join(','),
        queued_question_ids: queued.empty? ? nil : queued.join(','),
        last_attempt_at: attempt.sent_at,
        next_attempt_at: next_valid_attempt_time
      )
    end
    return attempt
  end

  def attempt_question(send_message: true, question: next_question)
    return if recipient.opted_out?
    unanswered_attempt = recipient.attempts.not_yet_responded.last

    return if question.nil? && unanswered_attempt.nil?

    if unanswered_attempt.nil?
      if question.for_recipient_students?
        return attempt_question_for_recipient_students(question: question)
      end

      attempt = recipient.attempts.create(
        schedule: schedule,
        recipient_schedule: self,
        question: question
      )
    end

    if send_message && (unanswered_attempt || attempt).send_message
      upcoming = upcoming_question_id_array
      queued = queued_question_id_array
      attempted = attempted_question_id_array

      if question.present?
        question_id = [question.id.to_s]
        upcoming = upcoming - question_id
        if unanswered_attempt.nil?
          attempted += question_id
          queued -= question_id
        else
          queued += question_id
        end
      end

      update_attributes(
        upcoming_question_ids: upcoming.empty? ? nil : upcoming.join(','),
        attempted_question_ids: attempted.empty? ? nil : attempted.join(','),
        queued_question_ids: queued.empty? ? nil : queued.join(','),
        last_attempt_at: (unanswered_attempt || attempt).sent_at,
        next_attempt_at: next_valid_attempt_time
      )
    end
    return (unanswered_attempt || attempt)
  end

  def next_valid_attempt_time
    local_time = (next_attempt_at + (60 * 60 * schedule.frequency_hours)).in_time_zone('Eastern Time (US & Canada)')
    local_time += 1.day while local_time.on_weekend?
    return local_time
  end

  def self.create_for_recipient(recipient_or_recipient_id, schedule, next_attempt_at=nil)
    if next_attempt_at.nil?
      next_attempt_at = Time.at(schedule.start_date.to_time.to_i + (60 * schedule.time))
      next_attempt_at += 1.day while next_attempt_at.on_weekend?
    end

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
