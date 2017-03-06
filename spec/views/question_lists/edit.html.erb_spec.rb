require 'rails_helper'

RSpec.describe "question_lists/edit", type: :view do
  before(:each) do
    @question_list = assign(:question_list, QuestionList.create!(
      :name => "MyString",
      :description => "MyText",
      :question_ids => "MyText"
    ))
  end

  it "renders the edit question_list form" do
    render

    assert_select "form[action=?][method=?]", question_list_path(@question_list), "post" do

      assert_select "input#question_list_name[name=?]", "question_list[name]"

      assert_select "textarea#question_list_description[name=?]", "question_list[description]"

      assert_select "input[name=?]", "question_list[question_id_array][]"
    end
  end
end
