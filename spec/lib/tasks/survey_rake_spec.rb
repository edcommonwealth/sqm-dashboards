require 'rails_helper'

describe "survey:attempt_questions" do
  include_context "rake"

  it 'should have environment as a prerequisite' do
    expect(subject.prerequisites).to include("environment")
  end

  describe "basic flow" do
    let(:now) {
      n = DateTime.now
      n += 1.day until n.on_weekday?
      return n
    }

    let(:ready_recipient_schedule)    { double('ready recipient schedule', attempt_question: nil) }
    let(:recipient_schedules)         { double("recipient schedules", ready: [ready_recipient_schedule]) }
    let(:active_schedule)             { double("active schedule", recipient_schedules: recipient_schedules) }

    it "finds all active schedules" do
      date = ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT20:00:00%z"))
      Timecop.freeze(date)

      expect(ready_recipient_schedule).to receive(:attempt_question)
      expect(active_schedule).to receive(:recipient_schedules)
      expect(Schedule).to receive(:active).and_return([active_schedule])
      subject.invoke
    end

    it "works only on weekdays" do
      now = DateTime.now
      now += 1.day until now.on_weekend?
      date = ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT20:00:00%z"))
      Timecop.freeze(date)

      expect(ready_recipient_schedule).to_not receive(:attempt_question)
      subject.invoke
    end
  end

  describe "complex flow" do
    let(:now) {
      n = DateTime.now
      n += 1.day until n.on_weekday?
      return n
    }

    let!(:school) { School.create!(name: 'School') }

    let!(:recipients) { create_recipients(school, 3) }
    let!(:recipient_list) do
      school.recipient_lists.create!(name: 'Parents', recipient_ids: recipients.map(&:id).join(','))
    end

    let!(:category) { Category.create(name: 'Category') }
    let!(:questions) { create_questions(3, category) }
    let!(:question_list) do
      QuestionList.create!(name: 'Parent Questions', question_ids: questions.map(&:id).join(','))
    end

    let!(:schedule) do
      Schedule.create!(
        name: 'Parent Schedule',
        recipient_list_id: recipient_list.id,
        question_list: question_list,
        frequency_hours: 24 * 7,
        start_date: Time.new,
        end_date: 1.year.from_now,
        time: 1200
      )
    end

    describe 'First attempt not at specified time' do
      before :each do
        now = DateTime.new
        now += 1.day until now.on_weekend?
        date = ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT19:00:00%z"))
        Timecop.freeze(date) { subject.invoke }
      end

      it 'should not create any attempts' do
        expect(Attempt.count).to eq(0)
      end
    end


    describe 'First attempt at specified time' do
      before :each do
        date = ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT20:00:00%z"))
        Timecop.freeze(date) { subject.invoke }
      end

      it 'should create the first attempt for each recipient' do
        recipients.each do |recipient|
          recipient.reload
          expect(recipient.attempts.count).to eq(1)
          attempt = recipient.attempts.first
          expect(attempt.sent_at).to be_present
          expect(attempt.answer_index).to be_nil
        end
      end
    end

    describe 'Second Attempts' do
      before :each do
        recipients.each do |recipient|
          recipient_schedule = schedule.recipient_schedules.for_recipient(recipient).first
          recipient_schedule.attempt_question
        end
      end

      describe 'Immediate' do
        before :each do
          subject.invoke
        end

        it 'should do nothing' do
          recipients.each do |recipient|
            recipient.reload
            expect(recipient.attempts.count).to eq(1)
          end
        end
      end

      describe 'A Week Later' do
        before :each do
          recipients[1].attempts.first.update_attributes(
            answer_index: 4,
            responded_at: Time.new
          )
          Timecop.freeze(now + 7) { subject.invoke }
        end

        it 'should resend the first question if unanswered by a recipient' do
          [recipients[0], recipients[2]].each do |recipient|
            recipient.reload
            expect(recipient.attempts.count).to eq(1)
            attempt = recipient.attempts.last
            expect(attempt.sent_at).to be > 1.day.ago
            expect(attempt.answer_index).to be_nil
          end
        end

        it 'should create the second attempt with a new question for each recipient who has answered the first question' do
          recipient = recipients[1]
          recipient.reload
          expect(recipient.attempts.count).to eq(2)
          attempt = recipient.attempts.last
          expect(attempt.sent_at).to be_present
          expect(attempt.answer_index).to be_nil

          first_attempt = recipient.attempts.first
          expect(first_attempt.question).to_not eq(attempt.question)
        end
      end

      describe 'And Then A Recipient Answers The First Attempt' do
        before :each do
          recipients[1].attempts.first.save_response(answer_index: 4)

          Timecop.freeze(now + 7)
          recipients.each do |recipient|
            recipient_schedule = schedule.recipient_schedules.for_recipient(recipient).first
            recipient_schedule.attempt_question
          end

          @existing_message_count = FakeSMS.messages.length

          Timecop.freeze(now + 8)
          recipients[2].attempts.first.save_response(answer_index: 3)
          subject.invoke
        end

        it 'should create the second attempt with a new question for each recipient who just answered the first question' do
          recipient = recipients[2]
          recipient.reload
          expect(recipient.attempts.count).to eq(2)
          attempt = recipient.attempts.last
          expect(attempt.sent_at).to be_present
          expect(attempt.answer_index).to be_nil

          first_attempt = recipient.attempts.first
          expect(first_attempt.question).to_not eq(attempt.question)
        end

        it 'should not send anything to anyone else' do
          expect(FakeSMS.messages.length).to eq(@existing_message_count + 2)
          expect(recipients[0].attempts.count).to eq(1)
          expect(recipients[1].attempts.count).to eq(2)
        end
      end
    end

    describe 'Multiple Students In A Family' do

      before :each do
        3.times do |i|
          recipients[1].students.create(name: "Student#{i}")
        end
      end

      let(:students_recipient) { recipients[1] }
      let(:students_recipient_schedule) {
        students_recipient.recipient_schedules.for_schedule(schedule).first
      }

      describe 'With A FOR_CHILD Question Is Asked' do
        let!(:date) { ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT20:00:00%z")) }

        before :each do
          questions.first.update_attributes(for_recipient_students: true)
          Timecop.freeze(date) { subject.invoke }
        end

        it 'should create one attempt per recipient regardless of students' do
          expect(FakeSMS.messages.length).to eq(6)
          recipients.each do |recipient|
            expect(recipient.attempts.count).to eq(1)
          end
        end

        it 'should store queued questions when an attempt is made on first student' do
          expect(students_recipient_schedule.queued_question_ids).to be_present
          queued_question_ids = students_recipient_schedule.queued_question_ids.split(/,/)
          expect(queued_question_ids.length).to eq(1)
          expect(queued_question_ids.first).to eq("#{questions[0].id}")
        end

        it 'should set the next_attempt_at to now when attempt is made on first student' do
          students_recipient.attempts.last.save_response(answer_index: 3)
          expect(students_recipient_schedule.reload.next_attempt_at).to eq(Time.new)
        end

        it 'should set the next_attempt_at in the future when an attempts are made on each student' do
          students_recipient.attempts.last.save_response(answer_index: 3)
          expect{students_recipient_schedule.attempt_question}.to change{students_recipient.attempts.count}.by(1)
          expect(students_recipient_schedule.reload.queued_question_ids).to be_present

          attempt = students_recipient.attempts.last
          expect(attempt.student).to eq(students_recipient.students[1])

          Timecop.freeze(date + 1.day)
          attempt.save_response(answer_index: 4)
          expect(students_recipient_schedule.reload.next_attempt_at).to eq(date + 1.day)

          expect{students_recipient_schedule.attempt_question}.to change{students_recipient.attempts.count}.by(1)
          expect(students_recipient_schedule.reload.queued_question_ids).to be_nil
          expect(students_recipient_schedule.reload.next_attempt_at).to_not eq(date + (60 * 60 * schedule.frequency_hours))

          attempt = students_recipient.attempts.last
          expect(attempt.student).to eq(students_recipient.students[2])

          Timecop.freeze(date + 2.days)
          attempt.save_response(answer_index: 2)
          expect(students_recipient_schedule.reload.next_attempt_at).to_not eq(date + 2.days)
        end

        it 'should mention the students name in the text' do
          expect(FakeSMS.messages[2].body).to match(/\(for Student0\)/)
        end

        it 'should not mention the students name in the text if the recipient has no student specified' do
          expect(FakeSMS.messages[0].body).to_not match(/\(for .*\)/)
        end

        it 'resends the question about the same student if not responded to' do
          message_count = FakeSMS.messages.length
          expect{students_recipient_schedule.attempt_question}.to change{students_recipient.attempts.count}.by(0)
          expect(FakeSMS.messages.length).to eq(message_count + 2)
          expect(FakeSMS.messages[message_count].body).to match(questions.first.text)
          expect(FakeSMS.messages[message_count].body).to match(/\(for Student0\)/)
        end

        it 'doesnt store any queued_question_ids when no students are present' do
          recipient_schedule = recipients[0].recipient_schedules.for_schedule(schedule).first
          expect(recipient_schedule.queued_question_ids).to be_nil
        end

      end

      describe 'With A General Question Is Asked' do
        before :each do
          subject.invoke
        end

        it 'should not queue up an questions regardless of how many students there are' do
          expect(students_recipient_schedule.queued_question_ids).to be_nil
        end

        it 'should not mention the students name in the text' do
          FakeSMS.messages.each do |message|
            expect(message.body).to_not match(/\(for .*\)/)
          end
        end

      end
    end

    describe 'One Student In A Family' do

      before :each do
        recipients[1].students.create(name: "Only Student")
      end

      let(:students_recipient) { recipients[1] }
      let(:students_recipient_schedule) {
        students_recipient.recipient_schedules.for_schedule(schedule).first
      }

      describe 'With A FOR_CHILD Question Is Asked' do
        let!(:date) { ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT20:00:00%z")) }

        before :each do
          questions.first.update_attributes(for_recipient_students: true)
          Timecop.freeze(date) { subject.invoke }
        end

        it 'should create one attempt per recipient regardless of students' do
          expect(FakeSMS.messages.length).to eq(6)
          recipients.each do |recipient|
            expect(recipient.attempts.count).to eq(1)
          end
        end

        it 'doesnt store any queued_question_ids' do
          expect(students_recipient_schedule.queued_question_ids).to be_nil
        end
      end
    end

    describe 'Opted Out Recipient' do

      before :each do
        recipients[1].update_attributes(opted_out: true)

        date = ActiveSupport::TimeZone["UTC"].parse(now.strftime("%Y-%m-%dT20:00:00%z"))
        Timecop.freeze(date) { subject.invoke }
      end

      it 'should create the first attempt for each recipient' do
        recipients.each_with_index do |recipient, index|
          recipient.reload
          if index == 1
            expect(recipient.attempts.count).to eq(0)
            expect(recipient.attempts.first).to be_nil
          else
            expect(recipient.attempts.count).to eq(1)
            attempt = recipient.attempts.first
            expect(attempt.sent_at).to be_present
            expect(attempt.answer_index).to be_nil
          end
        end
      end
    end

  end
end
