require 'rails_helper'

RSpec.describe "questions/edit", type: :view do
  before(:each) do
    @question = assign(:question, Question.create!(
      :text => "MyString",
      :option1 => "MyString",
      :option2 => "MyString",
      :option3 => "MyString",
      :option4 => "MyString",
      :option5 => "MyString",
      :category_id => 1
    ))
  end

  it "renders the edit question form" do
    render

    assert_select "form[action=?][method=?]", question_path(@question), "post" do

      assert_select "input#question_text[name=?]", "question[text]"

      assert_select "input#question_option1[name=?]", "question[option1]"

      assert_select "input#question_option2[name=?]", "question[option2]"

      assert_select "input#question_option3[name=?]", "question[option3]"

      assert_select "input#question_option4[name=?]", "question[option4]"

      assert_select "input#question_option5[name=?]", "question[option5]"

      assert_select "input#question_category_id[name=?]", "question[category_id]"
    end
  end
end
