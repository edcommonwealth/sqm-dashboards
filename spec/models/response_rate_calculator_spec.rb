require "rails_helper"

describe ResponseRateCalculator, type: :model do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }

  describe StudentResponseRateCalculator do
    let(:subcategory) { create(:subcategory) }
    let(:second_subcategory) { create(:subcategory_with_measures) }
    let(:sufficient_measure_1) { create(:measure, subcategory:) }
    let(:sufficient_scale_1) { create(:scale, measure: sufficient_measure_1) }
    let(:sufficient_measure_2) { create(:measure, subcategory:) }
    let(:sufficient_scale_2) { create(:scale, measure: sufficient_measure_2) }
    let(:sufficient_teacher_survey_item) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_student_survey_item_1) { create(:student_survey_item, scale: sufficient_scale_1) }
    let(:insufficient_student_survey_item_1) { create(:student_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_student_survey_item_2) { create(:student_survey_item, scale: sufficient_scale_2) }
    let(:sufficient_student_survey_item_3) { create(:student_survey_item, scale: sufficient_scale_2) }

    context ".raw_response_rate" do
      context "when no survey item responses exist" do
        before do
          create(:respondent, school:, academic_year:, pk: 20)
        end
        it "returns an average of the response rates for all grades" do
          expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 0
        end

        context "or when the count of survey items does not meet the minimum threshold" do
          before do
            create_list(:survey_item_response, 9, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                  school:, grade: 1)
          end
          it "returns an average of the response rates for all grades" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 0
          end
        end
      end

      context "when at least one survey item has sufficient responses" do
        before do
          create(:respondent, school:, academic_year:, total_students: 20, one: 20)
          create_list(:survey_item_response, 10, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                 school:, grade: 1)
        end

        context "and half of students responded" do
          it "reports a response rate of fifty percent" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                     academic_year:).rate).to eq 50
          end
        end

        context "and another unrelated subcategory has responses" do
          before do
            create_list(:survey_item_response, 10,
                        survey_item: second_subcategory.measures.first.scales.first.survey_items.first, academic_year:, school:, grade: 1)
          end

          it "does not count the responses for the unrelated subcategory" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                     academic_year:).rate).to eq 50
          end
        end

        context "there are responses for another survey item but not enough to meet the minimum threshold" do
          before do
            less_than_a_quarter_of_respondents_for_first_grade = 4
            create_list(:survey_item_response, less_than_a_quarter_of_respondents_for_first_grade, survey_item: insufficient_student_survey_item_1, academic_year:,
                                                                                                   school:, grade: 1)
          end
          it "returns an average of the response rates for all grades" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 50
          end
        end
      end

      context "when two survey items have sufficient responses" do
        before do
          create(:respondent, school:, academic_year:, total_students: 20, one: 20)
          create_list(:survey_item_response, 10, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                 school:, grade: 1)
          create_list(:survey_item_response, 20, survey_item: sufficient_student_survey_item_2, academic_year:,
                                                 school:, grade: 1)
        end

        context "and the response rate is a decimal number" do
          before do
            create_list(:survey_item_response, 1, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                  school:, grade: 1)
          end

          it "rounds the response rate to the nearest whole number" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                     academic_year:).rate).to eq 78
          end
        end

        context "one one question got half the students to respond and the other got all the students to respond" do
          it "reports a response rate that averages fifty and 100" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 75
          end
        end

        context "and another unrelated subcategory has responses" do
          before do
            create_list(:survey_item_response, 10,
                        survey_item: second_subcategory.measures.first.scales.first.survey_items.first, academic_year:, school:, grade: 1)
          end

          it "does not count the responses for the unrelated subcategory" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 75
          end
        end
      end

      context "when there survey items between two scales" do
        before do
          create(:respondent, school:, academic_year:, total_students: 20, one: 20)
          create_list(:survey_item_response, 20, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                 school:, grade: 1)
          create_list(:survey_item_response, 15, survey_item: sufficient_student_survey_item_2, academic_year:,
                                                 school:, grade: 1)
          create_list(:survey_item_response, 10, survey_item: sufficient_student_survey_item_3, academic_year:,
                                                 school:, grade: 1)
        end

        context "one scale got all students to respond and another scale got an average response rate of fifty percent" do
          it "computes the response rate by dividing the actual responses over possible responses" do
            # (20 + 15 + 10) / (20 + 20 + 20) * 100 = 75%
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 75
          end
        end

        context "and another unrelated subcategory has responses" do
          before do
            create_list(:survey_item_response, 10,
                        survey_item: second_subcategory.measures.first.scales.first.survey_items.first, academic_year:, school:, grade: 1)
          end

          it "does not count the responses for the unrelated subcategory" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 75
          end
        end
      end
      context "when two grades have sufficient responses" do
        context "and half of one grade responded and all of the other grade responded" do
          before do
            create(:respondent, school:, academic_year:, total_students: 20, one: 20, two: 20)
            create_list(:survey_item_response, 10, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                   school:, grade: 1)
            create_list(:survey_item_response, 20, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                   school:, grade: 2)
          end
          it "reports a response rate that averages fifty and 100" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 75
          end
        end

        context "and two grades responded to different questions at different rates" do
          before do
            create(:respondent, school:, academic_year:, total_students: 20, one: 20, two: 20)
            create_list(:survey_item_response, 10, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                   school:, grade: 1)
            create_list(:survey_item_response, 20, survey_item: sufficient_student_survey_item_2, academic_year:,
                                                   school:, grade: 2)
          end
          it "reports a response rate that averages fifty and 100" do
            expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 75
          end
        end
      end

      context "when two grades have different numbers of students" do
        before do
          create(:respondent, school:, academic_year:, total_students: 60, one: 40, two: 20)
          create_list(:survey_item_response, 20, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                 school:, grade: 1) # 50%
          create_list(:survey_item_response, 15, survey_item: sufficient_student_survey_item_2, academic_year:,
                                                 school:, grade: 2) # 75%
        end
        it "weights the average response rate by the number of students in each grade" do
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to be_within(0.01).of(58)
        end
      end

      context "when three grades have different numbers of students" do
        before do
          create(:respondent, school:, academic_year:, total_students: 120, one: 40, two: 20, three: 60)
          create_list(:survey_item_response, 20, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                 school:, grade: 1) # 50%
          create_list(:survey_item_response, 15, survey_item: sufficient_student_survey_item_2, academic_year:,
                                                 school:, grade: 2) # 75%
          create_list(:survey_item_response, 15, survey_item: sufficient_student_survey_item_2, academic_year:,
                                                 school:, grade: 3) # 25%
        end
        it "weights the average response rate by the number of students in each grade" do
          expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to be_within(0.01).of(42)
        end
      end

      context "when one grade gets surveyed but another does not, the grade that does not get surveyed is not counted" do
        before do
          create(:respondent, school:, academic_year:, total_students: 20, one: 20, two: 20)
          create_list(:survey_item_response, 10, survey_item: sufficient_student_survey_item_1, academic_year:,
                                                 school:, grade: 1)
        end
        it "reports a response rate that averages fifty and 100" do
          expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 50
        end
      end
    end

    context "when the average number of student responses is greater than the total possible responses" do
      before do
        create(:respondent, school:, academic_year:, total_students: 20, one: 20, two: 20)
        create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD * 11, survey_item: sufficient_student_survey_item_2,
                                                                                                academic_year:, school:, likert_score: 1, grade: 1)
      end
      it "returns 100 percent" do
        expect(StudentResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 100
      end
    end

    context "when no survey information exists for that school or year" do
      it "returns 100 percent" do
        expect(StudentResponseRateCalculator.new(subcategory:, school:, academic_year:).rate).to eq 100
      end
    end
  end

  describe TeacherResponseRateCalculator do
    let(:subcategory) { create(:subcategory) }
    let(:sufficient_measure_1) { create(:measure, subcategory:) }
    let(:sufficient_scale_1) { create(:scale, measure: sufficient_measure_1) }
    let(:sufficient_measure_2) { create(:measure, subcategory:) }
    let(:sufficient_scale_2) { create(:scale, measure: sufficient_measure_2) }
    let(:sufficient_teacher_survey_item_1) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_teacher_survey_item_2) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_teacher_survey_item_3) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:insufficient_teacher_survey_item_4) { create(:teacher_survey_item, scale: sufficient_scale_1) }
    let(:sufficient_student_survey_item_1) { create(:student_survey_item, scale: sufficient_scale_1) }
    let(:respondent) { create(:respondent, school:, academic_year:, total_teachers: 8) }

    before :each do
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item_1,
                                                                                         academic_year:, school:, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: sufficient_teacher_survey_item_2,
                                                                                         academic_year:, school:, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: sufficient_student_survey_item_1,
                                                                                         academic_year:, school:, likert_score: 4)
    end

    context "when the average number of teacher responses per question in a subcategory is at the threshold" do
      before :each do
        respondent
      end
      it "returns 25 percent" do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 25
      end
    end

    context "when the teacher response rate is not a whole number. eg 29.166%" do
      before do
        respondent
        create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD + 1, survey_item: sufficient_teacher_survey_item_3,
                                                                                               academic_year:, school:, likert_score: 1)
      end
      it "it will return the nearest whole number" do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 29
      end
    end

    context "when the average number of teacher responses is greater than the total possible responses" do
      before do
        respondent
        create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD * 11, survey_item: sufficient_teacher_survey_item_3,
                                                                                                academic_year:, school:, likert_score: 1)
      end
      it "returns 100 percent" do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 100
      end
    end

    context "when no survey information exists for that school and academic_year" do
      it "returns 100 percent" do
        expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                 academic_year:).rate).to eq 100
      end
    end

    context "when there is an imbalance in the response rate of the teacher items" do
      context "and one of the teacher items has no associated survey item responses" do
        before do
          respondent
          insufficient_teacher_survey_item_4
        end
        it "ignores the empty survey item and returns only the average response rate of teacher survey items with responses" do
          expect(TeacherResponseRateCalculator.new(subcategory:, school:,
                                                   academic_year:).rate).to eq 25
        end
      end
    end
  end
end
