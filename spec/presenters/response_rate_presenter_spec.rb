require "rails_helper"

describe ResponseRatePresenter do
  let(:academic_year) { create(:academic_year, range: "2022-23") }
  let(:school) { create(:school, name: "A school") }
  let(:respondents) { create(:respondent, school:, academic_year:, total_students: 40, total_teachers: 40) }
  let(:wrong_school) { create(:school, name: "Wrong school") }
  let(:wrong_academic_year) { create(:academic_year) }
  let(:wrong_respondents) do
    create(:respondent, school: wrong_school, academic_year: wrong_academic_year, total_students: 40,
                        total_teachers: 40)
  end

  let(:today) { Date.today }
  let(:yesterday) { Date.today - 1 }
  let(:two_days_ago) { Date.today - 2 }
  let(:three_days_ago) { Date.today - 3 }
  let(:student_survey_item) { create(:student_survey_item) }
  let(:teacher_survey_item) { create(:teacher_survey_item) }
  let(:oldest_student_survey_response) do
    create(:survey_item_response, school:, academic_year:, survey_item: student_survey_item,
                                  recorded_date: three_days_ago)
  end
  let(:newest_student_survey_response) do
    create(:survey_item_response, school:, academic_year:, survey_item: student_survey_item, recorded_date: yesterday)
  end
  let(:oldest_teacher_survey_response) do
    create(:survey_item_response, school:, academic_year:, survey_item: teacher_survey_item,
                                  recorded_date: three_days_ago)
  end
  let(:newest_teacher_survey_response) do
    create(:survey_item_response, school:, academic_year:, survey_item: teacher_survey_item, recorded_date: yesterday)
  end

  let(:wrong_student_survey_response) do
    create(:survey_item_response, school: wrong_school, academic_year: wrong_academic_year,
                                  survey_item: student_survey_item, recorded_date: two_days_ago)
  end
  let(:wrong_teacher_survey_response) do
    create(:survey_item_response, school: wrong_school, academic_year: wrong_academic_year,
                                  survey_item: teacher_survey_item, recorded_date: two_days_ago)
  end

  let(:filler_survey_item_responses_to_meet_sufficiency) do
    create_list(:survey_item_response, 10, school:, academic_year:,
                                           survey_item: student_survey_item, recorded_date: two_days_ago)
  end

  context ".date" do
    context "when focus is student" do
      before :each do
        oldest_student_survey_response
        newest_student_survey_response
        wrong_student_survey_response
        wrong_teacher_survey_response
        filler_survey_item_responses_to_meet_sufficiency
      end

      it "ignores all teacher items and only gets the modified date of the last student item" do
        date = ResponseRatePresenter.new(focus: :student, academic_year:, school:).date
        expect(date).to eq(newest_student_survey_response.recorded_date)
      end
    end
    context "when focus is teacher" do
      before :each do
        oldest_teacher_survey_response
        newest_teacher_survey_response
        wrong_student_survey_response
        wrong_teacher_survey_response
      end

      it "ignores all student responses and only gets the modified date of the last teacher item" do
        date = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).date
        expect(date).to eq(newest_teacher_survey_response.recorded_date)
      end
    end
  end

  context ".percentage" do
    before :each do
      respondents
      wrong_respondents
    end
    context "when no survey responses are found for a school" do
      it "returns a response rate of 0" do
        percentage = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).percentage
        expect(percentage).to eq(0)
      end
    end

    context "when there all possible teacher respondents answered questions" do
      before :each do
        create_list(:survey_item_response, 40, school:, academic_year:,
                                               survey_item: teacher_survey_item)
      end

      it "returns a response rate of 100" do
        percentage = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).percentage
        expect(percentage).to eq(100)
      end
    end

    context "when more teachers responded than staff the school" do
      before :each do
        create_list(:survey_item_response, 80, school:, academic_year:,
                                               survey_item: teacher_survey_item)
      end

      it "returns a response rate of 100" do
        percentage = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).percentage
        expect(percentage).to eq(100)
      end
    end

    context "when three quarters of the teachers responded to the survey" do
      before :each do
        create_list(:survey_item_response, 30, school:, academic_year:,
                                               survey_item: teacher_survey_item)
      end

      it "returns a response rate of 75" do
        percentage = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).percentage
        expect(percentage).to eq(75)
      end
    end
    context "when one quarter of the teachers responded to the survey" do
      before :each do
        create_list(:survey_item_response, 10, school:, academic_year:,
                                               survey_item: teacher_survey_item)
      end

      it "returns a response rate of 25" do
        percentage = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).percentage
        expect(percentage).to eq(25)
      end
    end
    context "When the percentage is not a round number" do
      before :each do
        create_list(:survey_item_response, 9, school:, academic_year:,
                                              survey_item: teacher_survey_item)
      end

      it "its rounded to the nearest integer" do
        percentage = ResponseRatePresenter.new(focus: :teacher, academic_year:, school:).percentage
        expect(percentage).to eq(23)
      end
    end

    context "when there all possible student respondents answered questions" do
      before :each do
        create_list(:survey_item_response, 40, school:, academic_year:,
                                               survey_item: student_survey_item)
      end

      it "returns a response rate of 100" do
        percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
        expect(percentage).to eq(100)
      end
    end
    context "when half of all students responded" do
      before :each do
        create_list(:survey_item_response, 20, school:, academic_year:,
                                               survey_item: student_survey_item)
      end

      it "returns a response rate of 50" do
        percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
        expect(percentage).to eq(50)
      end
    end

    context "when only a subset of grades was given the survey" do
      before :each do
        respondents.one = 20
        respondents.two = 20
        respondents.three = 20
        respondents.four = 20
        respondents.five = 20
        respondents.save
      end
      context "and only first grade was given the survey" do
        context "and all the first grade responded" do
          before :each do
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 1)
          end
          it "returns a response rate of 100" do
            percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
            expect(percentage).to eq(100)
          end
        end

        context "and half of first grade responded" do
          before :each do
            create_list(:survey_item_response, 10, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 1)
          end
          it "returns a response rate of 50" do
            percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
            expect(percentage).to eq(50)
          end
        end
      end

      context "and two grades responded" do
        context "and both grades responded fully" do
          before :each do
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 1)
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 2)
          end
          it "returns a response rate of 100" do
            percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
            expect(percentage).to eq(100)
          end
        end
        context "and half of first grade responded" do
          before :each do
            create_list(:survey_item_response, 10, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 1)
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 2)
          end
          it "returns a response rate of 75" do
            percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
            expect(percentage).to eq(75)
          end
        end
        context "and a quarter of first grade responded" do
          before :each do
            create_list(:survey_item_response, 5, school:, academic_year:,
                                                  survey_item: student_survey_item, grade: 1)
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 2)
          end
          it "returns a response rate of 63 (rounded up from 62.5)" do
            percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
            expect(percentage).to eq(63)
          end
        end
      end

      context "and three grades responded" do
        context "and all three grades responded fully" do
          before :each do
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 1)
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 2)
            create_list(:survey_item_response, 20, school:, academic_year:,
                                                   survey_item: student_survey_item, grade: 3)
          end
          it "returns a response rate of 100" do
            percentage = ResponseRatePresenter.new(focus: :student, academic_year:, school:).percentage
            expect(percentage).to eq(100)
          end
        end
      end
    end
  end
end
