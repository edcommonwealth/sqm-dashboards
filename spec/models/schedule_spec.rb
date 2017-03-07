require 'rails_helper'

describe Schedule do

  describe "active" do

    let!(:school) { School.create!(name: 'School') }
    let!(:recipient_list) { RecipientList.create!(name: 'Parents', recipient_id_array: [1, 2, 3]) }
    let!(:kids_recipient_list) { RecipientList.create!(name: 'Kids', recipient_id_array: [4, 5, 6]) }
    let!(:question_list) { QuestionList.create!(name: 'Questions', question_id_array: [1, 2, 3]) }

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

    it 'finds active schedules' do
      active = Schedule.active
      expect(active.length).to eq(2)
    end

  end
end
