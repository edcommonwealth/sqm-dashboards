require 'rails_helper'

describe Schedule do

  let!(:school) { School.create!(name: 'School') }

  let!(:recipients) { create_recipients(school, 3) }
  let!(:recipient_list) do
    school.recipient_lists.create!(name: 'Parents', recipient_ids: recipients.map(&:id).join(','))
  end

  let!(:kid_recipients) { create_recipients(school, 3) }
  let!(:kids_recipient_list) do
    school.recipient_lists.create!(name: 'Kids', recipient_ids: kid_recipients.map(&:id).join(','))
  end

  let!(:questions) { create_questions(3) }
  let!(:question_list) do 
    QuestionList.create!(name: 'Questions', question_ids: questions.map(&:id).join(','))
  end

  let(:default_schedule_params) {
    {
      school: school,
      recipient_list: recipient_list,
      question_list: question_list,
      name: 'Parents Schedule',
      description: 'Schedule for parent questions',
      start_date: 1.month.ago,
      end_date: 11.months.from_now,
      active: true
    }
  }

  let!(:active_schedule) do
    Schedule.create!(default_schedule_params)
  end

  let!(:active_schedule_kids) do
    Schedule.create!(default_schedule_params.merge!(name: 'Kids Schedule', recipient_list: kids_recipient_list))
  end

  let!(:old_schedule) {
    Schedule.create!(default_schedule_params.merge!(start_date: 13.month.ago, end_date: 1.months.ago))
  }

  let!(:paused_schedule) {
    Schedule.create!(default_schedule_params.merge!(active: false))
  }

  describe "active" do
    it 'finds active schedules' do
      active = Schedule.active
      expect(active.length).to eq(2)
    end
  end

  it 'creates a recipient_schedule for every recipient when created' do
    expect(active_schedule.recipient_schedules.length).to eq(3)
  end

end
