require 'rails_helper'

RSpec.describe "recipients/new", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(
      name: 'School'
    ))

    @recipient = assign(:recipient, Recipient.new(
      :name => "MyString",
      :phone => "MyString",
      :gender => "MyString",
      :race => "MyString",
      :ethnicity => "MyString",
      :home_language_id => 1,
      :income => "MyString",
      :opted_out => false,
      :school_id => @school.to_param
    ))
  end

  it "renders new recipient form" do
    render

    assert_select "form[action=?][method=?]", school_recipients_path(@school, @recipient), "post" do

      assert_select "input#recipient_name[name=?]", "recipient[name]"

      assert_select "input#recipient_phone[name=?]", "recipient[phone]"

      assert_select "input#recipient_gender[name=?]", "recipient[gender]"

      assert_select "input#recipient_race[name=?]", "recipient[race]"

      assert_select "input#recipient_ethnicity[name=?]", "recipient[ethnicity]"

      assert_select "input#recipient_home_language_id[name=?]", "recipient[home_language_id]"

      assert_select "input#recipient_income[name=?]", "recipient[income]"

    end
  end
end
