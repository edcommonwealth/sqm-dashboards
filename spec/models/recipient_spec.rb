require 'rails_helper'

describe Recipient do
  describe "Import" do
    let(:school) { School.create!(name: 'School') }
    let(:data) { "name,phone\rJared,111-222-333\rLauren,222-333-4444\rAbby,333-444-5555\r" }
    let(:file) { instance_double('File', path: 'path') }

    it "should parse file contents and return a result" do
      expect(File).to receive(:open).with('path', universal_newline: false, headers: true) { StringIO.new(data) }
      Recipient.import(school, file)
      expect(Recipient.count).to eq(3)
      expect(Recipient.all.map(&:name)).to eq(['Jared', 'Lauren', 'Abby'])
      expect(Recipient.all.map(&:school).uniq).to eq([school])
    end
  end

  describe "When Deleted" do
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

    it 'should delete all recipient_schedules and update all recipient_lists' do
      expect do
        recipients[1].destroy
      end.to change { schedule.recipient_schedules.count }.from(3).to(2)

      expect(recipient_list.recipient_ids).to eq("#{recipients[0].id},#{recipients[2].id}")

    end
  end
end
