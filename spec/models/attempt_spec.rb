require 'rails_helper'

RSpec.describe Attempt, type: :model do

  let!(:school) { School.create!(name: 'School') }

  let!(:recipient) { school.recipients.create(name: 'name', phone: "#{1}" * 9) }
  let!(:recipient_list) do
    school.recipient_lists.create!(name: 'Parents', recipient_ids: "#{recipient.id}")
  end

  let!(:category) { Category.create(name: 'Category') }
  let!(:question) { create_questions(1, category).first }
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

  describe 'after_save' do
    let!(:school_categories) { SchoolCategory.for(attempt.recipient.school, attempt.question.category) }

    it 'creates the associated school_category' do
      expect(school_categories.count).to eq(1)
      expect(school_categories.first.attempt_count).to eq(1)
      expect(school_categories.first.response_count).to eq(0)
      expect(school_categories.first.answer_index_total).to eq(0)
    end

    describe 'after_update' do
      before :each do
        attempt.update_attributes(answer_index: 4)
      end

      it 'updates associated school_categories' do
        expect(school_categories.count).to eq(1)
        expect(school_categories.first.attempt_count).to eq(1)
        expect(school_categories.first.response_count).to eq(1)
        expect(school_categories.first.answer_index_total).to eq(4)
      end
    end
  end

  describe 'counters' do
    it 'are updated when an attempt is created' do
      expect(recipient.attempts_count).to eq(1)
      expect(recipient.responses_count).to eq(0)
    end

    it 'are updated when an attempt is destroyed' do
      attempt.destroy
      expect(recipient.attempts_count).to eq(0)
      expect(recipient.responses_count).to eq(0)
    end

    it 'are updated when an attempt is responded to' do
      attempt.update_attributes(answer_index: 2)
      expect(recipient.attempts_count).to eq(1)
      expect(recipient.responses_count).to eq(1)
    end

    it 'are updated when an attempt is responded to with an open-ended response' do
      attempt.update_attributes(open_response_id: 1)
      expect(recipient.attempts_count).to eq(1)
      expect(recipient.responses_count).to eq(1)
    end
  end

  describe 'send_message' do
    before :each do
      Timecop.freeze
      attempt.send_message
    end

    it 'should contact the Twilio API' do
      expect(FakeSMS.messages.length).to eq(2)

      expect(FakeSMS.messages.first.to).to eq('111111111')
      expect(FakeSMS.messages.first.body).to eq("Question 0:1")

      expect(FakeSMS.messages.last.to).to eq('111111111')
      expect(FakeSMS.messages.last.body).to eq("Option 0:1 A: Reply 1\nOption 0:1 B: 2\nOption 0:1 C: 3\nOption 0:1 D: 4\nOption 0:1 E: 5")
    end

    it 'should update sent_at' do
      expect(attempt.sent_at).to eq(Time.new)
    end

    it 'should update the recipient phone number' do
      expect(attempt.recipient.reload.phone).to eq('+1111111111')
    end
  end
end
