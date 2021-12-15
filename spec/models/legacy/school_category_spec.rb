require 'rails_helper'

module Legacy
  RSpec.describe SchoolCategory, type: :model do
    let!(:school1) { School.create!(name: 'School 1') }
    let!(:school2) { School.create!(name: 'School 2') }

    let!(:school1recipients) { create_recipients(school1, 4) }
    let!(:school2recipients) { create_recipients(school2, 4) }

    let!(:category1) { Category.create!(name: 'Category 1') }
    let!(:category2) { Category.create!(name: 'Category 2') }

    let!(:category1questions) { create_questions(3, category1) }
    let!(:category2questions) { create_questions(3, category2) }

    let!(:attempt1) do
      Attempt.create!(question: category1questions[0], recipient: school1recipients[0], answer_index: 2)
    end
    let!(:attempt2) { Attempt.create!(question: category1questions[0], recipient: school1recipients[1]) }
    let!(:attempt3) do
      Attempt.create!(question: category1questions[0], recipient: school1recipients[2], answer_index: 3)
    end
    let!(:attempt4) do
      Attempt.create!(question: category1questions[0], recipient: school2recipients[0], answer_index: 4)
    end
    let!(:attempt5) do
      Attempt.create!(question: category1questions[1], recipient: school1recipients[0], answer_index: 5)
    end
    let!(:attempt6) do
      Attempt.create!(question: category1questions[2], recipient: school1recipients[0], answer_index: 5)
    end
    let!(:attempt7) do
      Attempt.create!(question: category2questions[0], recipient: school1recipients[0], answer_index: 3)
    end
    let!(:attempt8) do
      Attempt.create!(question: category2questions[1], recipient: school1recipients[1], answer_index: 1)
    end

    let!(:school_category1) { SchoolCategory.for(school1, category1).first }

    describe 'aggregated_responses' do
      xit 'should provide the count and sum of all attempts' do
        expect(school_category1.aggregated_responses).to eq(
          attempt_count: 5,
          response_count: 4,
          answer_index_total: 15
        )
      end
    end

    describe 'answer_index_average' do
      xit 'should provide the average answer_index for all responses' do
        expect(school_category1.answer_index_average).to eq(15.0 / 4.0)
      end
    end

    describe 'sync_aggregated_responses' do
      let!(:category3) { Category.create!(name: 'Category 3', parent_category: category1) }

      let!(:category3questions) { create_questions(3, category3) }

      let!(:attempt7) do
        Attempt.create!(question: category3questions[0], recipient: school1recipients[0], answer_index: 4)
      end
      let!(:attempt8) do
        Attempt.create!(question: category3questions[0], recipient: school1recipients[1], answer_index: 1)
      end
      let!(:attempt9) { Attempt.create!(question: category3questions[0], recipient: school1recipients[2]) }
      let!(:attempt10) do
        Attempt.create!(question: category3questions[1], recipient: school1recipients[1], answer_index: 5)
      end
      let!(:attempt11) do
        Attempt.create!(question: category3questions[1], recipient: school2recipients[0], answer_index: 5)
      end

      let!(:school_category3) { SchoolCategory.for(school1, category3).first }

      xit 'should update attributes and parent_category school_category attributes' do
        school_category3.sync_aggregated_responses

        school_category3.reload
        expect(school_category3.attempt_count).to eq(4)
        expect(school_category3.response_count).to eq(3)
        expect(school_category3.answer_index_total).to eq(10)

        school_category1.reload
        expect(school_category1.attempt_count).to eq(9)
        expect(school_category1.response_count).to eq(7)
        expect(school_category1.answer_index_total).to eq(25)
      end
    end
  end
end
