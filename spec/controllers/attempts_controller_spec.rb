require 'rails_helper'

RSpec.describe AttemptsController, type: :controller do

  let(:valid_session) { {} }

  let!(:recipients) { create_recipients(school, 2) }
  let!(:recipient_list) do
    school.recipient_lists.create!(name: 'Parents', recipient_ids: recipients.map(&:id).join(','))
  end

  let!(:category) { Category.create(name: 'Test Category')}
  let!(:questions) { create_questions(3, category) }
  let!(:question_list) do
    QuestionList.create!(name: 'Parent Questions', question_ids: questions.map(&:id).join(','))
  end

  let(:schedule) { Schedule.create(name: 'Test Schedule', question_list: question_list, recipient_list: recipient_list) }
  let(:school) { School.create!(name: 'School') }

  let(:recipient_schedule) { RecipientSchedule.create(recipient: recipients.first, schedule: schedule, next_attempt_at: Time.now) }
  let(:recipient_schedule2) { RecipientSchedule.create(recipient: recipients.last, schedule: schedule, next_attempt_at: Time.now) }

  let!(:first_attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipients.first,
      recipient_schedule: recipient_schedule,
      question: questions.first,
      sent_at: Time.new
    )
  }
  let!(:attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipients.first,
      recipient_schedule: recipient_schedule,
      question: questions.first,
      sent_at: Time.new
    )
  }
  let!(:attempt2) {
    Attempt.create(
      schedule: schedule,
      recipient: recipients.last,
      recipient_schedule: recipient_schedule2,
      question: questions.first,
      sent_at: Time.new
    )
  }


  describe "POST #twilio" do
    context "with valid params" do
      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+0000000000','To' => '2223334444','Body' => '3','NumMedia' => '0'}
      }

      before :each do
        post :twilio, params: twilio_attributes
      end

      it 'creates the first attempt with response for the question' do
        expect(attempt.question.attempts.for_school(school).with_answer.count).to eq(1)
      end

      it "updates the last attempt by recipient phone number" do
        attempt.reload
        expect(attempt.answer_index).to eq(3)
        expect(attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
        expect(attempt.responded_at).to be_present

        expect(first_attempt.answer_index).to be_nil
        expect(first_attempt.twilio_details).to be_nil
        expect(first_attempt.responded_at).to be_nil
      end

      it "sends back a message" do
        expect(response.body).to eq "We've registered your response of \"Option 0:3 C\". You are the first person to respond to this question. Once more people have responded you will be able to see all responses at: http://test.host/schools/school/categories/test-category"
      end

      context "with second response" do
        let(:twilio_attributes2) {
          {'MessageSid' => 'fwefwefewfewfasfsdfdf','AccountSid' => 'wefwegdbvcbrtnrn','MessagingServiceSid' => 'dfvdfvegbdfb','From' => '+1111111111','To' => '2223334444','Body' => '4','NumMedia' => '0'}
        }

        before :each do
          post :twilio, params: twilio_attributes2
        end

        it 'updates the second attempt with response for the school' do
          expect(attempt.question.attempts.for_school(school).with_answer.count).to eq(2)
        end

        it "updates the attempt from the second recipient" do
          attempt2.reload
          expect(attempt2.answer_index).to eq(4)
          expect(attempt2.twilio_details).to eq(twilio_attributes2.with_indifferent_access.to_yaml)
          expect(attempt2.responded_at).to be_present
        end

        it "sends back a message" do
          expect(response.body).to eq "We've registered your response of \"Option 0:3 D\". 2 people have responded to this question so far. To see all responses visit: http://test.host/schools/school/categories/test-category"
        end
      end
    end

    ['stOp', 'cANcel', 'QuIt', 'no'].each do |command|
      context "with #{command} command" do
        let(:twilio_attributes) {
          {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+0000000000','To' => '2223334444','Body' => command,'NumMedia' => '0'}
        }

        it "updates the last attempt by recipient phone number" do
          post :twilio, params: twilio_attributes
          attempt.reload
          expect(attempt.answer_index).to be_nil
          expect(attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
          expect(attempt.recipient).to be_opted_out
        end

        it "sends back a message" do
          post :twilio, params: twilio_attributes
          expect(response.body).to eq('Thank you, you have been opted out of these messages and will no longer receive them.')
        end
      end
    end

    ['staRt', 'reSUme', 'rEstaRt', 'Yes', 'go'].each do |command|
      context "with #{command} command" do
        before :each do
          attempt.recipient.update(opted_out: true)
        end

        let(:twilio_attributes) {
          {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+0000000000','To' => '2223334444','Body' => command,'NumMedia' => '0'}
        }

        it "updates the last attempt by recipient phone number" do
          expect(attempt.recipient).to be_opted_out
          post :twilio, params: twilio_attributes
          attempt.reload
          expect(attempt.answer_index).to be_nil
          expect(attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
          expect(attempt.recipient).to_not be_opted_out
        end

        it "sends back a message" do
          post :twilio, params: twilio_attributes
          expect(response.body).to eq('Thank you, you will now begin receiving messages again.')
        end
      end
    end

    ['skip', 'i dont know', "i don't know", 'next'].each do |command|
      context "with #{command} command" do
        let(:twilio_skip_attributes) {
          {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+0000000000','To' => '2223334444','Body' => command,'NumMedia' => '0'}
        }

        it "updates the last attempt by recipient phone number" do
          post :twilio, params: twilio_skip_attributes
          attempt.reload
          expect(attempt.answer_index).to be_nil
          expect(attempt.responded_at).to be_present
          expect(attempt.twilio_details).to eq(twilio_skip_attributes.with_indifferent_access.to_yaml)
          expect(attempt.recipient).to_not be_opted_out

          school_attempts = attempt.question.attempts.for_school(school)
          expect(school_attempts.with_answer.count).to eq(0)
          expect(school_attempts.with_no_answer.count).to eq(3)
          expect(school_attempts.not_yet_responded.count).to eq(2)
        end

        it "sends back a message" do
          post :twilio, params: twilio_skip_attributes
          expect(response.body).to eq('Thank you, this question has been skipped.')
        end
      end
    end
  end

  describe "POST #twilio with response to repeated question" do
    context "with valid params" do

      let!(:recent_first_attempt) {
        first_attempt.update_attributes(sent_at: Time.new)
        return first_attempt
      }

      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+0000000000','To' => '2223334444','Body' => '2','NumMedia' => '0'}
      }

      before :each do
        post :twilio, params: twilio_attributes
      end

      it "updates the first attempt (that now has the most recent sent_at)" do
        recent_first_attempt.reload
        expect(recent_first_attempt.answer_index).to eq(2)
        expect(recent_first_attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
        expect(recent_first_attempt.responded_at).to be_present

        expect(attempt.answer_index).to be_nil
        expect(attempt.twilio_details).to be_nil
        expect(attempt.responded_at).to be_nil

        expect(recent_first_attempt.id).to be < attempt.id
      end
    end
  end
end
