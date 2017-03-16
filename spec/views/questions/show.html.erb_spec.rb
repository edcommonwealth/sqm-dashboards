require 'rails_helper'

RSpec.describe "questions/show", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(name: 'School'))
    @question = assign(:question, Question.create!(
      :text => "Question Text",
      :option1 => "Option1",
      :option2 => "Option2",
      :option3 => "Option3",
      :option4 => "Option4",
      :option5 => "Option5",
      :category => Category.create!(name: 'Category Name')
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/School/)
    expect(rendered).to match(/Question Text/)
    expect(rendered).to match(/Option1/)
    expect(rendered).to match(/Option2/)
    expect(rendered).to match(/Option3/)
    expect(rendered).to match(/Option4/)
    expect(rendered).to match(/Option5/)
    expect(rendered).to match(/Category Name/)
  end
end
