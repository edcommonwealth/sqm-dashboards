require 'rails_helper'

RSpec.describe Respondent, type: :model do
  describe 'grade_counts' do
    let(:single_grade_of_respondents) { create(:respondent, one: 10) }
    let(:two_grades_of_respondents) { create(:respondent, pk: 10, k: 5, one: 0, two: 0, three: 0) }
    let(:three_grades_of_respondents) { create(:respondent, one: 10, two: 5, twelve: 6, eleven: 0) }
    context 'when the student respondents include one or more counts for the number of respondents' do
      it 'returns a hash with only the grades that have a non-zero count of students' do
        expect(single_grade_of_respondents.one).to eq(10)
        expect(single_grade_of_respondents.counts_by_grade).to eq({ 1 => 10 })
        expect(two_grades_of_respondents.counts_by_grade).to eq({ -1 => 10, 0 => 5 })
        expect(three_grades_of_respondents.counts_by_grade).to eq({ 1 => 10, 2 => 5, 12 => 6 })
      end
    end
  end
end
