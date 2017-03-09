require 'rails_helper'

RSpec.describe RecipientSchedule, type: :model do

  let!(:school) { School.create!(name: 'School') }

  let!(:recipient) { create_recipients(school, 1).first }
  let!(:recipient_list) do
    school.recipient_lists.create!(name: 'Parents', recipient_ids: "#{recipient.id}")
  end

  let!(:questions) { create_questions(3) }
  let!(:question_list) do
    QuestionList.create!(name: 'Parent Questions', question_ids: questions.map(&:id).join(','))
  end

  let!(:schedule) do
    Schedule.create!(
      name: 'Parent Schedule',
      recipient_list_id: recipient_list.id,
      question_list: question_list,
      random: false,
      frequency_hours: 24 * 7
    )
  end
  let!(:recipient_schedule) { schedule.recipient_schedules.for(recipient).first }

  let!(:not_ready_recipient_schedule) do
    RecipientSchedule.create!(
      recipient: recipient,
      schedule: schedule,
      upcoming_question_ids: '1,3',
      attempted_question_ids: '2',
      last_attempt_at: 1.day.ago,
      next_attempt_at: 1.day.ago + (60 * 60 * schedule.frequency_hours)
    )
  end

  describe 'ready' do
    subject { schedule.recipient_schedules.ready }

    it ('should only provide recipient_schedules who are ready to send a message') do
      expect(subject.length).to eq(1)
      expect(subject.first).to eq(recipient_schedule)
    end
  end

  describe 'next_question' do
    it 'should provide the next question from the upcoming_question_ids list' do
      expect(recipient_schedule.next_question).to eq(questions.first)
    end
  end

  describe 'attempt_question' do
    before :each do
      Timecop.freeze
    end

    let!(:attempt) { recipient_schedule.attempt_question }

    it 'should make an attempt to ask the next question' do
      expect(attempt).to be_persisted
      expect(attempt.recipient).to eq(recipient)
      expect(attempt.schedule).to eq(schedule)
      expect(attempt.recipient_schedule).to eq(recipient_schedule)
      expect(attempt.question).to eq(questions.first)
      expect(attempt.sent_at.to_i).to eq(Time.new.to_i)
      expect(attempt.answer_index).to be_nil
    end

    it 'should update the upcoming_questions_ids' do
      expect(recipient_schedule.upcoming_question_ids).to eq(questions[1..2].map(&:id).join(','))
    end

    it 'should update the attempted_question_ids' do
      expect(recipient_schedule.attempted_question_ids).to eq(questions.first.id.to_s)
    end

    it 'should update last_attempt_at' do
      expect(recipient_schedule.last_attempt_at.to_i).to eq(Time.new.to_i)
    end

    it 'should update next_attempt_at' do
      expect(recipient_schedule.next_attempt_at.to_i).to eq((Time.new + (60 * 60 * schedule.frequency_hours)).to_i)
    end
  end
end
