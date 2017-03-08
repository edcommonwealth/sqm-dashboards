require 'rails_helper'

RSpec.describe RecipientSchedule, type: :model do

  let(:question) { Question.create!(text: 'What is the question?', option1: 'A', option2: 'B', option3: 'C', option4: 'D', option5: 'E')}
  let(:question_list) { QuestionList.create(name: 'Parent Questions', question_ids: "#{question.id},2,3")}

  let(:recipient) { Recipient.create!(name: 'Parent', phone: '1112223333') }
  let(:recipient_list) { RecipientList.create(name: 'Parent List', recipient_ids: recipient.id.to_s)}

  let(:schedule) { Schedule.create!(name: 'Parent Schedule', recipient_list_id: recipient_list.id, question_list: question_list) }

  let!(:recipient_schedule) do
    RecipientSchedule.create!(
      recipient: recipient,
      schedule: schedule,
      upcoming_question_ids: "#{question.id},3",
      attempted_question_ids: '2',
      last_attempt_at: 2.weeks.ago
    )
  end

  describe 'next_question' do
    it 'should provide the next question from the upcoming_question_ids list' do
      expect(recipient_schedule.next_question).to eq(question)
    end
  end

  describe 'make_attempt' do
    before :each do
      Timecop.freeze
    end

    let!(:attempt) { recipient_schedule.make_attempt }

    it 'should make an attempt to ask the next question' do
      expect(attempt).to be_persisted
      expect(attempt.recipient).to eq(recipient)
      expect(attempt.schedule).to eq(schedule)
      expect(attempt.recipient_schedule).to eq(recipient_schedule)
      expect(attempt.question).to eq(question)
      expect(attempt.sent_at.to_i).to eq(Time.new.to_i)
      expect(attempt.answer_index).to be_nil
    end

    it 'should update the upcoming_questions_ids' do
      expect(recipient_schedule.upcoming_question_ids).to eq('3')
    end

    it 'should update the attempted_question_ids' do
      expect(recipient_schedule.attempted_question_ids).to eq("2,#{question.id}")
    end

    it 'should update last_attempt_at' do
      expect(recipient_schedule.last_attempt_at.to_i).to eq(Time.new.to_i)
    end

  end
end
