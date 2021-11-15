require 'rails_helper'

module Legacy
  RSpec.describe "legacy/recipient_lists/new", type: :view do
    before(:each) do
      @school = assign(:school, School.create!(name: 'School'))

      @recipient_list = assign(:recipient_list, RecipientList.new(
        :name => "MyString",
        :description => "MyText",
        :recipient_ids => "MyText",
        :school_id => @school.id
      ))
    end

    it "renders new recipient_list form" do
      render

      assert_select "form[action=?][method=?]", legacy_school_legacy_recipient_lists_path(@school, @recipient_list), "post" do
        assert_select "input#recipient_list_name[name=?]", "recipient_list[name]"

        assert_select "textarea#recipient_list_description[name=?]", "recipient_list[description]"

        assert_select "input[name=?]", "recipient_list[recipient_id_array][]"
      end
    end
  end
end
