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
      expect(FakeSMS.messages.first.body).to eq(question.text)
      expect(FakeSMS.messages.first.to).to eq(recipient.phone)
    end

    it 'should update sent_at' do
      expect(attempt.sent_at).to eq(Time.new)
    end
  end
end
