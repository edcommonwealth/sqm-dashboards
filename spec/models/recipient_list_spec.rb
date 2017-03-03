require 'rails_helper'

describe Recipient do
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
end
