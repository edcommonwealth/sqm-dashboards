require 'rails_helper'
RSpec.describe Sample, type: :model do
  let(:american_indian) { Race.create(qualtrics_code: 1) }
  let(:asian) { Race.create(qualtrics_code: 2) }
  let(:black) { Race.create(qualtrics_code: 3) }
  let(:latinx) { Race.create(qualtrics_code: 4) }
  let(:white) { Race.create(qualtrics_code: 5) }
  let(:middle_eastern) { Race.create(qualtrics_code: 8) }
  let(:unknown) { Race.create(qualtrics_code: 99) }
  let(:multiracial) { Race.create(qualtrics_code: 100) }
  let(:races) { [american_indian, asian, black, latinx, white, middle_eastern, unknown, multiracial] }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:multiracial_student) do
    student = create(:student)
    student.races << american_indian
    student.races << asian
    student.races << multiracial
    student
  end

  before :each do
    7.times do |index|
      student = create(:student)
      student.races << races[index]
      create(:survey_item_response, response_id: student.response_id, student:, school:, academic_year:)
    end
  end
  describe '#count_all_students' do
    context 'When called without params' do
      it 'returns a count of all students' do
        sample = Sample.new(slug: school.slug, range: academic_year.range)
        expect(sample.count_all_students).to eq 7
      end
    end
  end

  describe '#count_students' do
    context 'When called with a race param' do
      context 'and there are no multirace students' do
        it 'returns a count of the race passed in' do
          sample = Sample.new(slug: school.slug, range: academic_year.range)
          expect(sample.count_students(race: american_indian)).to eq 1
          expect(sample.count_students(race: asian)).to eq 1
          expect(sample.count_students(race: black)).to eq 1
          expect(sample.count_students(race: latinx)).to eq 1
          expect(sample.count_students(race: white)).to eq 1
          expect(sample.count_students(race: middle_eastern)).to eq 1
          expect(sample.count_students(race: unknown)).to eq 1
        end
      end

      context 'when there are multirace students' do
        before do
          create(:survey_item_response, response_id: multiracial_student.response_id, student: multiracial_student,
                                        school:, academic_year:)
        end
        it 'counts the student for all categories' do
          sample = Sample.new(slug: school.slug, range: academic_year.range)
          expect(sample.count_students(race: american_indian)).to eq 2
          expect(sample.count_students(race: asian)).to eq 2
          expect(sample.count_students(race: multiracial)).to eq 1
        end
      end
    end
  end
end
