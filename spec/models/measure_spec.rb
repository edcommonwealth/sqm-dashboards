require 'rails_helper'

RSpec.describe Measure, type: :model do
  let(:measure) { create(:measure) }
  let(:scale) { create(:scale, measure:) }
  let(:teacher_scale) { create(:teacher_scale, measure:) }
  let(:student_scale) { create(:student_scale, measure:) }
  let(:admin_scale) { create(:admin_scale, measure:) }
  let(:school) { create(:school) }
  let(:short_form_school) { create(:school) }
  let(:academic_year) { create(:academic_year) }

  let(:admin_watch_low_benchmark) { 2.0 }
  let(:admin_growth_low_benchmark) { 3.0 }
  let(:admin_approval_low_benchmark) { 4.0 }
  let(:admin_ideal_low_benchmark) { 5.0 }

  let(:student_watch_low_benchmark) { 1.5 }
  let(:student_growth_low_benchmark) { 2.5 }
  let(:student_approval_low_benchmark) { 3.5 }
  let(:student_ideal_low_benchmark) { 4.5 }

  let(:teacher_watch_low_benchmark) { 1.2 }
  let(:teacher_growth_low_benchmark) { 2.2 }
  let(:teacher_approval_low_benchmark) { 3.2 }
  let(:teacher_ideal_low_benchmark) { 4.2 }

  before do
    create(:respondent, school:, academic_year:)
    create(:survey, school:, academic_year:)
    create(:respondent, school: short_form_school, academic_year:)
    create(:survey, school: short_form_school, academic_year:, form: 'short')
  end

  describe 'benchmarks' do
    context 'when a measure includes only one admin data item' do
      before do
        create(:admin_data_item, scale:,
                                 watch_low_benchmark: admin_watch_low_benchmark,
                                 growth_low_benchmark: admin_growth_low_benchmark,
                                 approval_low_benchmark: admin_approval_low_benchmark,
                                 ideal_low_benchmark: admin_ideal_low_benchmark)
      end
      it 'returns a watch low benchmark equal to the admin data item watch low benchmark' do
        expect(measure.watch_low_benchmark).to be 2.0
      end

      # it 'returns the source as an admin_data_item' do
      #   expect(measure.sources).to eq [Source.new(name: :admin_data, collection: measure.admin_data_items)]
      # end
    end

    context 'when a measure includes only student survey items' do
      before do
        create(:student_survey_item, scale:,
                                     watch_low_benchmark: student_watch_low_benchmark,
                                     growth_low_benchmark: student_growth_low_benchmark,
                                     approval_low_benchmark: student_approval_low_benchmark,
                                     ideal_low_benchmark: student_ideal_low_benchmark)
      end
      it 'returns a watch low benchmark equal to the student survey item watch low benchmark ' do
        expect(measure.watch_low_benchmark).to be 1.5
      end
      it 'returns a warning low benchmark equal to the student survey item warning low benchmark ' do
        expect(measure.warning_low_benchmark).to eq 1
      end
      # it 'returns the source as student_surveys' do
      #   expect(measure.sources).to eq [Source.new(name: :student_surveys, collection: measure.student_survey_items)]
      # end
    end

    context 'when a measure includes only teacher survey items' do
      before do
        create(:teacher_survey_item, scale:,
                                     watch_low_benchmark: teacher_watch_low_benchmark,
                                     growth_low_benchmark: teacher_growth_low_benchmark,
                                     approval_low_benchmark: teacher_approval_low_benchmark,
                                     ideal_low_benchmark: teacher_ideal_low_benchmark)
      end
      it 'returns a watch low benchmark equal to the teacher survey item watch low benchmark ' do
        expect(measure.watch_low_benchmark).to be 1.2
      end
      it 'returns a warning low benchmark equal to the teacher survey item warning low benchmark ' do
        expect(measure.warning_low_benchmark).to eq 1
      end
      # it 'returns the source as teacher_surveys' do
      #   expect(measure.sources).to eq [Source.new(name: :teacher_surveys, collection: measure.teacher_survey_items)]
      # end
    end

    context 'when a measure includes admin data and student survey items' do
      before do
        create_list(:admin_data_item, 3, scale:,
                                         watch_low_benchmark: admin_watch_low_benchmark,
                                         growth_low_benchmark: admin_growth_low_benchmark,
                                         approval_low_benchmark: admin_approval_low_benchmark,
                                         ideal_low_benchmark: admin_ideal_low_benchmark)

        create(:student_survey_item, scale:,
                                     watch_low_benchmark: student_watch_low_benchmark,
                                     growth_low_benchmark: student_growth_low_benchmark,
                                     approval_low_benchmark: student_approval_low_benchmark,
                                     ideal_low_benchmark: student_ideal_low_benchmark)
      end

      it 'returns the average of admin and student benchmarks where each admin data item has a weight of 1 and student survey items all together have a weight of 1' do
        # (2*3 + 1.5)/4
        expect(measure.watch_low_benchmark).to be 1.875
      end
      # it 'returns the source as admin and student survey items' do
      #   expect(measure.sources).to eq [Source.new(name: :admin_data, collection: measure.admin_data_items),
      #                                  Source.new(name: :student_surveys, collection: measure.student_survey_items)]
      # end
    end

    context 'when a measure includes admin data and teacher survey items' do
      before do
        create_list(:admin_data_item, 3, scale:,
                                         watch_low_benchmark: admin_watch_low_benchmark,
                                         growth_low_benchmark: admin_growth_low_benchmark,
                                         approval_low_benchmark: admin_approval_low_benchmark,
                                         ideal_low_benchmark: admin_ideal_low_benchmark)

        create(:teacher_survey_item, scale:,
                                     watch_low_benchmark: teacher_watch_low_benchmark,
                                     growth_low_benchmark: teacher_growth_low_benchmark,
                                     approval_low_benchmark: teacher_approval_low_benchmark,
                                     ideal_low_benchmark: teacher_ideal_low_benchmark)
      end

      it 'returns the average of admin and teacher benchmarks where each admin data item has a weight of 1 and teacher survey items all together have a weight of 1' do
        # (2*3 + 1.2)/4
        expect(measure.watch_low_benchmark).to be 1.8
      end
      # it 'returns the source as admin and teacher survey items' do
      #   expect(measure.sources).to eq [Source.new(name: :admin_data, collection: measure.admin_data_items),
      #                                  Source.new(name: :teacher_surveys, collection: measure.teacher_survey_items)]
      # end
    end

    context 'when a measure includes student and teacher survey items' do
      before do
        create_list(:student_survey_item, 3, scale:,
                                             watch_low_benchmark: student_watch_low_benchmark,
                                             growth_low_benchmark: student_growth_low_benchmark,
                                             approval_low_benchmark: student_approval_low_benchmark,
                                             ideal_low_benchmark: student_ideal_low_benchmark)

        create_list(:teacher_survey_item, 3, scale:,
                                             watch_low_benchmark: teacher_watch_low_benchmark,
                                             growth_low_benchmark: teacher_growth_low_benchmark,
                                             approval_low_benchmark: teacher_approval_low_benchmark,
                                             ideal_low_benchmark: teacher_ideal_low_benchmark)
      end

      it 'returns the average of student and teacher benchmarks where teacher survey items all together have a weight of 1 and all student survey items have a weight of 1' do
        # (1.2+ 1.5)/2
        expect(measure.watch_low_benchmark).to be 1.35
      end
      # it 'returns the source as student and teacher survey items' do
      #   expect(measure.sources).to eq [Source.new(name: :student_surveys, collection: measure.student_survey_items),
      #                                  Source.new(name: :teacher_surveys, collection: measure.teacher_survey_items)]
      # end
    end

    context 'when a measure includes admin data and student and teacher survey items' do
      before do
        create_list(:admin_data_item, 3, scale:,
                                         watch_low_benchmark: admin_watch_low_benchmark,
                                         growth_low_benchmark: admin_growth_low_benchmark,
                                         approval_low_benchmark: admin_approval_low_benchmark,
                                         ideal_low_benchmark: admin_ideal_low_benchmark)
        create_list(:student_survey_item, 3, scale: student_scale,
                                             watch_low_benchmark: student_watch_low_benchmark,
                                             growth_low_benchmark: student_growth_low_benchmark,
                                             approval_low_benchmark: student_approval_low_benchmark,
                                             ideal_low_benchmark: student_ideal_low_benchmark)

        create_list(:teacher_survey_item, 3, scale: teacher_scale,
                                             watch_low_benchmark: teacher_watch_low_benchmark,
                                             growth_low_benchmark: teacher_growth_low_benchmark,
                                             approval_low_benchmark: teacher_approval_low_benchmark,
                                             ideal_low_benchmark: teacher_ideal_low_benchmark)
      end

      it 'returns the average of admin and teacher benchmarks where each admin data item has a weight of 1 and teacher survey items all together have a weight of 1, and student surveys have a weight of 1' do
        # (2 * 3 + 1.2 + 1.5)/ 5
        expect(measure.watch_low_benchmark).to be_within(0.001).of 1.74
        # (3 * 3 + 2.2 + 2.5)/ 5
        expect(measure.growth_low_benchmark).to be_within(0.001).of 2.74
        # (4 * 3 + 3.2 + 3.5)/ 5
        expect(measure.approval_low_benchmark).to be_within(0.001).of 3.74
        # (5 * 3 + 4.2 + 4.5)/ 5
        expect(measure.ideal_low_benchmark).to be_within(0.001).of 4.74
      end

      # it 'returns the source as admin student and teacher survey items' do
      #   expect(measure.sources).to eq [Source.new(name: :admin_data, collection: measure.admin_data_items),
      #                                  Source.new(name: :student_surveys, collection: measure.student_survey_items),
      #                                  Source.new(name: :teacher_surveys, collection: measure.teacher_survey_items)]
      # end
    end
  end

  describe '.score' do
    context 'when the measure includes only teacher data' do
      let(:teacher_survey_item_1) { create(:teacher_survey_item, scale: teacher_scale) }
      let(:teacher_survey_item_2) { create(:teacher_survey_item, scale: teacher_scale) }
      let(:teacher_survey_item_3) { create(:teacher_survey_item, scale: teacher_scale) }

      context "and the number of responses for each of the measure's survey items meets the teacher threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_1, academic_year:, school:, likert_score: 3)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_2, academic_year:, school:, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_3, academic_year:, school:, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(measure.score(school:, academic_year:).average).to eq 4
        end

        it 'affirms that the result meets the teacher threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be true
        end

        it 'reports the result does not meeet student threshold' do
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be false
        end
      end

      context "and the average number of responses across the measure's survey items meets the teacher threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD + 1, survey_item: teacher_survey_item_1, academic_year:, school:,
                                                                                                 likert_score: 3)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: teacher_survey_item_2, academic_year:, school:,
                                                                                             likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1, survey_item: teacher_survey_item_3, academic_year:, school:,
                                                                                                 likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          average_score = 4
          expect(measure.score(school:, academic_year:).average).to be_within(0.001).of(average_score)
        end
      end

      context "and none of the measure's survey items meets the teacher threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1, survey_item: teacher_survey_item_1, academic_year:, school:,
                                                                                                 likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1, survey_item: teacher_survey_item_2, academic_year:, school:,
                                                                                                 likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1, survey_item: teacher_survey_item_3, academic_year:, school:,
                                                                                                 likert_score: rand)
        end

        it 'returns nil' do
          expect(measure.score(school:, academic_year:).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be false
        end
      end

      context "and the average number of responses across the measure's survey items does not meet the teacher threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: teacher_survey_item_1, academic_year:, school:,
                                                                                             likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1, survey_item: teacher_survey_item_2, academic_year:, school:,
                                                                                                 likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1, survey_item: teacher_survey_item_3, academic_year:, school:,
                                                                                                 likert_score: rand)
        end

        it 'returns nil' do
          expect(measure.score(school:, academic_year:).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be false
        end
      end
    end

    context 'when the measure includes only student data' do
      let(:student_survey_item_1) { create(:student_survey_item, scale: student_scale) }
      let(:student_survey_item_2) { create(:student_survey_item, scale: student_scale) }
      let(:student_survey_item_3) { create(:student_survey_item, scale: student_scale) }
      let(:short_form_student_survey_item_1) { create(:student_survey_item, scale: student_scale, on_short_form: true) }
      let(:short_form_student_survey_item_2) { create(:student_survey_item, scale: student_scale, on_short_form: true) }
      let(:short_form_student_survey_item_3) { create(:student_survey_item, scale: student_scale, on_short_form: true) }

      context "and the number of responses for each of the measure's survey items meets the student threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year:, school:, likert_score: 3)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_2, academic_year:, school:, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_3, academic_year:, school:, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(measure.score(school:, academic_year:).average).to eq 4
        end

        it 'affirms that the result meets the student threshold' do
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be true
        end
        it 'notes that the result does not meet the teacher threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be false
        end
      end

      context "and the average number of responses across the measure's survey items meets the student threshold " do
        before :each do
          create_list(:survey_item_response,  SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD + 1, survey_item: student_survey_item_1, academic_year:,
                                                                                                  school:, likert_score: 3)
          create_list(:survey_item_response,  SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: student_survey_item_2, academic_year:,
                                                                                              school:, likert_score: 4)
          create_list(:survey_item_response,  SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1, survey_item: student_survey_item_3, academic_year:,
                                                                                                  school:, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          average_score = 4
          expect(measure.score(school:, academic_year:).average).to be_within(0.001).of(average_score)
        end
      end

      context "and none of the measure's survey items meets the student threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1, survey_item: student_survey_item_1, academic_year:,
                                                                                                 school:, likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1, survey_item: student_survey_item_2, academic_year:,
                                                                                                 school:, likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1, survey_item: student_survey_item_3, academic_year:,
                                                                                                 school:, likert_score: rand)
        end

        it 'returns nil' do
          expect(measure.score(school:, academic_year:).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be false
        end
      end

      context "and the average number of responses across the measure's survey items does not meet the student threshold " do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1, survey_item: student_survey_item_1, academic_year:,
                                                                                                 school:, likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                      survey_item: student_survey_item_2, academic_year:, school:, likert_score: rand)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: student_survey_item_3, academic_year:,
                                                                                             school:, likert_score: rand)
        end

        it 'returns nil' do
          expect(measure.score(school:, academic_year:).average).to be_nil
        end

        it 'affirms that the result does not meet the threshold' do
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be false
        end
      end

      context 'and the school is a short form school' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year:, school: short_form_school, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_2, academic_year:, school: short_form_school, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_3, academic_year:, school: short_form_school, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: short_form_student_survey_item_1, academic_year:, school: short_form_school, likert_score: 3)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: short_form_student_survey_item_2, academic_year:, school: short_form_school, likert_score: 4)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: short_form_student_survey_item_3, academic_year:, school: short_form_school, likert_score: 5)
        end

        it 'ignores any responses not on the short form and gives the average of short form survey items' do
          expect(measure.score(school: short_form_school, academic_year:).average).to eq 4
        end
      end
    end

    context 'when the measure includes both teacher and student data' do
      let(:teacher_survey_item_1) { create(:teacher_survey_item, scale: teacher_scale) }
      let(:student_survey_item_1) { create(:student_survey_item, scale: student_scale) }

      context 'and there is sufficient teacher data and sufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_1, academic_year:, school:, likert_score: 5)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year:, school:, likert_score: 5)
        end

        it 'returns the average of the likert scores of the survey items' do
          expect(measure.score(school:, academic_year:).average).to eq 5
        end

        it 'affirms that the result does meet the thresholds' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be true
        end

        context 'and a different measure in the same year exists' do
          before :each do
            different_measure = create(:measure)
            different_scale = create(:teacher_scale, measure: different_measure)
            different_teacher_survey_item = create(:teacher_survey_item, scale: different_scale)
            create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                        survey_item: different_teacher_survey_item, academic_year:, school:, likert_score: 1)
          end

          it 'affirms the additional measures do not change the scores for the original measure' do
            expect(measure.score(school:, academic_year:).average).to eq 5
          end
        end

        context 'and data exists for the same measure but a different school' do
          before do
            different_school = create(:school)
            create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                        survey_item: teacher_survey_item_1, academic_year:, school: different_school, likert_score: 1)
          end

          it 'affirms the data for the different school does not affect the average for the original school' do
            expect(measure.score(school:, academic_year:).average).to eq 5
          end
        end

        context 'and data exists for the same measure but a different year' do
          before do
            different_year = create(:academic_year, range: '1111-12')

            create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                        survey_item: teacher_survey_item_1, academic_year: different_year, school:, likert_score: 1)
          end

          it 'affirms the data for the different year does not affect the average for the original year' do
            expect(measure.score(school:, academic_year:).average).to eq 5
          end
        end
      end

      context 'and there is sufficient teacher data and insufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                      survey_item: teacher_survey_item_1, academic_year:, school:, likert_score: 5)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                      survey_item: student_survey_item_1, academic_year:, school:, likert_score: 1)
        end

        it 'returns the average of the likert scores of the teacher survey items' do
          expect(measure.score(school:, academic_year:).average).to eq 5
        end

        it 'affirms that the result meets the teacher threshold but not the student threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be true
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be false
        end
      end

      context 'and there is insufficient teacher data and sufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                      survey_item: teacher_survey_item_1, academic_year:, school:, likert_score: 1)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD,
                      survey_item: student_survey_item_1, academic_year:, school:, likert_score: 5)
        end

        it 'returns the average of the likert scores of the student survey items' do
          expect(measure.score(school:, academic_year:).average).to eq 5
        end

        it 'affirms that the result meets the student threshold but not the teacher threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be false
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be true
        end
      end

      context 'and there is insufficient teacher data and insufficient student data' do
        before :each do
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD - 1,
                      survey_item: teacher_survey_item_1, academic_year:, school:)
          create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                      survey_item: student_survey_item_1, academic_year:, school:)
        end

        it 'returns nil' do
          expect(measure.score(school:, academic_year:).average).to be_nil
        end

        it 'affirms that the result does not meet either threshold' do
          expect(measure.score(school:, academic_year:).meets_teacher_threshold?).to be false
          expect(measure.score(school:, academic_year:).meets_student_threshold?).to be false
        end
      end
    end

    context 'when the measure includes admin data' do
      let(:admin_data_item) { create(:admin_data_item, scale: admin_scale) }
      let(:admin_data_item_2) { create(:admin_data_item, scale: admin_scale) }
      context 'and the admin data does not meet the sufficiency threshold' do
        it 'affirms the returned score does not meet the admin data threshold' do
          expect(measure.score(school:, academic_year:).meets_admin_data_threshold?).to be false
        end
      end
      context 'and the admin data does meet the sufficiency threshold' do
        before :each do
          create(:admin_data_value, admin_data_item:, school:, academic_year:)
          create(:admin_data_value, admin_data_item: admin_data_item_2, school:, academic_year:)
        end

        it 'affirms the returned score does meet the admin data threshold' do
          expect(measure.score(school:, academic_year:).meets_admin_data_threshold?).to be true
        end
      end
    end
  end
end
