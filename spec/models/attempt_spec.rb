require 'rails_helper'

RSpec.describe Attempt, type: :model do

  let!(:school) { School.create!(name: 'School') }

  let!(:recipient) { create_recipients(school, 1).first }
  let!(:recipient_list) do
    school.recipient_lists.create!(name: 'Parents', recipient_ids: "#{recipient.id}")
  end

  let!(:question) { create_questions(1).first }
  let!(:question_list) do
    QuestionList.create!(name: 'Parent Questions', question_ids: "#{question.id}")
  end

  let(:schedule) { Schedule.create!(name: 'Parent Schedule', recipient_list_id: recipient_list.id, question_list: question_list) }

  let(:recipient_schedule) do
    RecipientSchedule.create!(
      recipient: recipient,
      schedule: schedule,
      upcoming_question_ids: "#{question.id},3",
      attempted_question_ids: '2',
      last_attempt_at: 2.weeks.ago,
      next_attempt_at: Time.new
    )
  end

  let!(:attempt) do
    recipient.attempts.create(
      schedule: schedule,
      recipient_schedule: recipient_schedule,
      question: question
    )
  end

  describe 'send_message' do
    before :each do
      Timecop.freeze
      attempt.send_message
    end

    it 'should contact the Twilio API' do
      expect(FakeSMS.messages.length).to eq(1)
      expect(FakeSMS.messages.first.body).to eq("Question 0:1\n\rOption 0:1 A: Reply 1\n\rOption 0:1 B: Reply 2\n\rOption 0:1 C: Reply 3\n\rOption 0:1 D: Reply 4\n\rOption 0:1 E: Reply 5")
      expect(FakeSMS.messages.first.to).to eq('1111111111')
    end

    it 'should update sent_at' do
      expect(attempt.sent_at).to eq(Time.new)
    end

    it 'should update the recipient phone number' do
      expect(attempt.recipient.reload.phone).to eq('+11111111111')
    end
  end
end
