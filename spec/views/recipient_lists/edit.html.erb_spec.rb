require 'rails_helper'

RSpec.describe "recipient_lists/edit", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(
      :name => "School"
    ))

    @recipient_list = assign(:recipient_list, RecipientList.create!(
      :name => "MyString",
      :description => "MyText",
      :recipient_ids => "1,2,3",
      :school_id => @school.id
    ))
  end

  it "renders the edit recipient_list form" do
    render

    assert_select "form[action=?][method=?]", school_recipient_list_path(@school, @recipient_list), "post" do

      assert_select "input#recipient_list_name[name=?]", "recipient_list[name]"

      assert_select "textarea#recipient_list_description[name=?]", "recipient_list[description]"

      assert_select "input[name=?]", "recipient_list[recipient_id_array][]"
    end
  end
end
