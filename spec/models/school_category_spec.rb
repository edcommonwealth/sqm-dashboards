require 'rails_helper'

RSpec.describe SchoolCategory, type: :model do

  let!(:school1) { School.create!(name: 'School 1') }
  let!(:school2) { School.create!(name: 'School 2') }

  let!(:school1recipients) { create_recipients(school1, 4) }
  let!(:school2recipients) { create_recipients(school2, 4) }

  let!(:category1) { Category.create!(name: 'Category 1') }
  let!(:category2) { Category.create!(name: 'Category 2') }

  let!(:questions) { create_questions(3, category1) }

  let!(:attempt1) { Attempt.create(question: questions[0], recipient: school1recipients[0], answer_index: 2)}
  let!(:attempt2) { Attempt.create(question: questions[0], recipient: school1recipients[1])}
  let!(:attempt3) { Attempt.create(question: questions[0], recipient: school1recipients[2], answer_index: 3)}
  let!(:attempt4) { Attempt.create(question: questions[0], recipient: school2recipients[0], answer_index: 4)}

  let!(:school_category) { SchoolCategory.for(school1, category1).first }

  describe 'aggregated_responses' do
    it 'should provide the count and sum of all attempts' do
      expect(school_category.aggregated_responses).to eq(
        attempt_count: 3,
        response_count: 2,
        answer_index_total: 5
      )
    end
  end


end
