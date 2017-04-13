require 'rails_helper'

RSpec.describe AttemptsController, type: :controller do

  let(:valid_session) { {} }

  let(:schedule) { Schedule.new }
  let(:school) { School.create!(name: 'School') }

  let(:recipient) { school.recipients.create!(name: 'Recipient', phone: '+11231231234') }
  let(:recipient_schedule) { RecipientSchedule.new }
  let(:recipient2) { school.recipients.create!(name: 'Recipient2', phone: '+12342342345') }
  let(:recipient_schedule2) { RecipientSchedule.new }

  let(:category) { Category.create!(name: 'Category') }
  let(:question) { create_questions(1, category).first }
  let!(:first_attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipient,
      recipient_schedule: recipient_schedule,
      question: question
    )
  }
  let!(:attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipient,
      recipient_schedule: recipient_schedule,
      question: question
    )
  }
  let!(:attempt2) {
    Attempt.create(
      schedule: schedule,
      recipient: recipient2,
      recipient_schedule: recipient_schedule2,
      question: question
    )
  }


  describe "POST #twilio" do
    context "with valid params" do
      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+11231231234','To' => '2223334444','Body' => '3','NumMedia' => '0'}
      }

      before :each do
        post :twilio, params: twilio_attributes
      end

      it 'creates the first attempt with response for the question' do
        expect(attempt.question.attempts.for_school(school).with_response.count).to eq(1)
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
        expect(response.body).to eq "We've registered your response of \"Option 0:1 C\". You are the first person to respond to this question. Once more people have responded you will be able to see all responses at http://test.host/schools/school/categories/category"
      end

      context "with second response" do
        let(:twilio_attributes2) {
          {'MessageSid' => 'fwefwefewfewfasfsdfdf','AccountSid' => 'wefwegdbvcbrtnrn','MessagingServiceSid' => 'dfvdfvegbdfb','From' => '+12342342345','To' => '2223334444','Body' => '4','NumMedia' => '0'}
        }

        before :each do
          post :twilio, params: twilio_attributes2
        end

        it 'creates the second attempt with response for the question' do
          expect(attempt.question.attempts.for_school(school).with_response.count).to eq(2)
        end

        it "updates the attempt from the second recipient" do
          attempt2.reload
          expect(attempt2.answer_index).to eq(4)
          expect(attempt2.twilio_details).to eq(twilio_attributes2.with_indifferent_access.to_yaml)
          expect(attempt2.responded_at).to be_present
        end

        it "sends back a message" do
          expect(response.body).to eq "We've registered your response of \"Option 0:1 D\". 2 people have responded to this question so far. To see all responses visit http://test.host/schools/school/categories/category"
        end
      end
    end

    context 'with stop params' do
      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+11231231234','To' => '2223334444','Body' => 'sToP','NumMedia' => '0'}
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
end
