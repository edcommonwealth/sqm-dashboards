require 'rails_helper'

RSpec.describe Attempt, type: :model do

  let(:question) { Question.create!(text: 'What is the question?', option1: 'A', option2: 'B', option3: 'C', option4: 'D', option5: 'E')}
  let(:question_list) { QuestionList.create(name: 'Parent Questions', question_ids: "#{question.id},2,3")}

  let(:recipient) { Recipient.create!(name: 'Parent', phone: '1112223333') }
  let(:recipient_list) { RecipientList.create(name: 'Parent List', recipient_ids: recipient.id.to_s)}

  let(:schedule) { Schedule.create!(name: 'Parent Schedule', recipient_list_id: recipient_list.id, question_list: question_list) }

  let(:recipient_schedule) do
    RecipientSchedule.create!(
      recipient: recipient,
      schedule: schedule,
      upcoming_question_ids: "#{question.id},3",
      attempted_question_ids: '2',
      last_attempt_at: 2.weeks.ago
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
