require 'rails_helper'

describe RecipientList do
  describe "Save" do
    it "should convert the recipient_id_array into the recipient_ids attribute" do
      recipient_list = RecipientList.create(name: 'Name', recipient_id_array: ['', '1', '2', '3'])
      expect(recipient_list).to be_a(RecipientList)
      expect(recipient_list).to be_persisted
      expect(recipient_list.recipient_ids).to eq('1,2,3')

      recipient_list.update(recipient_id_array: ['3', '', '4', '5', '6'])
      expect(recipient_list.reload.recipient_ids).to eq('3,4,5,6')
    end
  end

  describe "when edited" do
    let!(:school) { School.create!(name: 'School') }

    let!(:recipients) { create_recipients(school, 3) }
    let!(:recipient_list) do
      school.recipient_lists.create!(name: 'Parents', recipient_ids: recipients.map(&:id).join(','))
    end

    let!(:questions) { create_questions(3) }
    let!(:question_list) do
      QuestionList.create!(name: 'Parent Questions', question_ids: questions.map(&:id).join(','))
    end

    let!(:schedule) do
      Schedule.create!(
        name: 'Parent Schedule',
        recipient_list_id: recipient_list.id,
        question_list: question_list,
        random: false,
        frequency_hours: 24 * 7
      )
    end

    it 'should delete recipient_schedules if a recipient is removed' do
      modified_recipient_ids = recipients.map(&:id)[0,2].join(',')
      expect do
        recipient_list.update_attributes(recipient_ids: modified_recipient_ids)
      end.to change { schedule.recipient_schedules.count }.from(3).to(2)
    end

    it 'should create recipient_schedules if a recipient is added' do
      new_recipients = create_recipients(school, 2)
      expect do
        recipient_list.update_attributes(recipient_ids: (recipients + new_recipients).map(&:id).join(','))
      end.to change { schedule.recipient_schedules.count }.from(3).to(5)
    end
  end
end
