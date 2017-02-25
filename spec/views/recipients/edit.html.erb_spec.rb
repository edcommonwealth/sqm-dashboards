require 'rails_helper'

RSpec.describe "recipients/edit", type: :view do
  before(:each) do
    @recipient = assign(:recipient, Recipient.create!(
      :name => "MyString",
      :phone => "MyString",
      :gender => "MyString",
      :race => "MyString",
      :ethnicity => "MyString",
      :home_language_id => 1,
      :income => "MyString",
      :opted_out => false,
      :school_id => 1
    ))
  end

  it "renders the edit recipient form" do
    render

    assert_select "form[action=?][method=?]", recipient_path(@recipient), "post" do

      assert_select "input#recipient_name[name=?]", "recipient[name]"

      assert_select "input#recipient_phone[name=?]", "recipient[phone]"

      assert_select "input#recipient_gender[name=?]", "recipient[gender]"

      assert_select "input#recipient_race[name=?]", "recipient[race]"

      assert_select "input#recipient_ethnicity[name=?]", "recipient[ethnicity]"

      assert_select "input#recipient_home_language_id[name=?]", "recipient[home_language_id]"

      assert_select "input#recipient_income[name=?]", "recipient[income]"

      assert_select "input#recipient_opted_out[name=?]", "recipient[opted_out]"

      assert_select "input#recipient_school_id[name=?]", "recipient[school_id]"
    end
  end
end
