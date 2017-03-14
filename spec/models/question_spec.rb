require 'rails_helper'

RSpec.describe Question, type: :model do

  let!(:school1) { School.create!(name: 'School 1') }
  let!(:school2) { School.create!(name: 'School 2') }

  let!(:school1recipients) { create_recipients(school1, 5) }
  let!(:school2recipients) { create_recipients(school2, 4) }

  let!(:category1) { Category.create!(name: 'Resources') }
  let!(:category2) { Category.create!(name: 'Category 2') }

  let!(:category1questions) { create_questions(3, category1) }
  let!(:category2questions) { create_questions(3, category2) }
  let(:question) { category1questions.first }

  let!(:attempt1) { Attempt.create!(question: category1questions[0], recipient: school1recipients[0], answer_index: 3)}
  let!(:attempt2) { Attempt.create!(question: category1questions[0], recipient: school1recipients[1], answer_index: 2)}
  let!(:attempt3) { Attempt.create!(question: category1questions[0], recipient: school1recipients[2])}
  let!(:attempt4) { Attempt.create!(question: category1questions[0], recipient: school1recipients[3], answer_index: 3)}
  let!(:attempt5) { Attempt.create!(question: category1questions[0], recipient: school2recipients[0], answer_index: 4)}
  let!(:attempt6) { Attempt.create!(question: category1questions[1], recipient: school1recipients[0], answer_index: 5)}
  let!(:attempt7) { Attempt.create!(question: category1questions[2], recipient: school1recipients[0], answer_index: 5)}
  let!(:attempt8) { Attempt.create!(question: category2questions[0], recipient: school1recipients[0], answer_index: 3)}
  let!(:attempt9) { Attempt.create!(question: category2questions[1], recipient: school1recipients[1], answer_index: 1)}

  describe 'aggregated_responses_for_school' do

    let(:aggregated_responses) { question.aggregated_responses_for_school(school1) }

    it 'aggregates all attempts with responses for the question for a given school' do
      expect(aggregated_responses.count).to eq(3)
      expect(aggregated_responses.responses.to_a).to eq([attempt1, attempt2, attempt4])
      expect(aggregated_responses.answer_index_total).to eq(8)
    end

    it 'should calculate answer_index_average' do
      expect(aggregated_responses.answer_index_average).to eq(8.0 / 3)
    end

    it 'should calculate the most popular answer' do
      expect(aggregated_responses.most_popular_answer).to eq(question.option3)
    end

    it 'should provide access to the question and category' do
      expect(aggregated_responses.question).to eq(question)
      expect(aggregated_responses.category).to eq(question.category)
    end

  end


end
