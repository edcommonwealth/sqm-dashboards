require 'rails_helper'
include AnalyzeHelper

describe GroupedBarColumnPresenter do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year, range: '1900-01') }
  let(:another_academic_year) { create(:academic_year, range: '2000-01') }
  let(:academic_years) { [academic_year, another_academic_year] }
  let(:year_index) { academic_years.find_index(academic_year) }
  let(:watch_low_benchmark) { 2 }
  let(:growth_low_benchmark) { 3 }
  let(:approval_low_benchmark) { 4 }
  let(:ideal_low_benchmark) { 4.5 }

  let(:measure_with_student_survey_items) { create(:measure, name: 'Student measure') }
  let(:scale_with_student_survey_item) { create(:student_scale, measure: measure_with_student_survey_items) }
  let(:student_survey_item) do
    create(:student_survey_item, scale: scale_with_student_survey_item,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end

  let(:measure_with_teacher_survey_items) { create(:measure, name: 'Teacher measure') }
  let(:scale_with_teacher_survey_item) { create(:teacher_scale, measure: measure_with_teacher_survey_items) }
  let(:teacher_survey_item) do
    create(:teacher_survey_item, scale: scale_with_teacher_survey_item,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end

  let(:measure_composed_of_student_and_teacher_items) { create(:measure, name: 'Student and teacher measure') }
  let(:student_scale_for_composite_measure) do
    create(:student_scale, measure: measure_composed_of_student_and_teacher_items)
  end
  let(:student_survey_item_for_composite_measure) do
    create(:student_survey_item, scale: student_scale_for_composite_measure,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end
  let(:teacher_scale_for_composite_measure) do
    create(:teacher_scale, measure: measure_composed_of_teacher_and_teacher_items)
  end
  let(:teacher_survey_item_for_composite_measure) do
    create(:teacher_survey_item, scale: teacher_scale_for_composite_measure,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end

  let(:measure_without_admin_data_items) do
    create(
      :measure,
      name: 'Some Title'
    )
  end

  let(:student_presenter) do
    StudentGroupedBarColumnPresenter.new measure: measure_with_student_survey_items, school:, academic_years:,
                                         position: 0
  end

  let(:teacher_presenter) do
    TeacherGroupedBarColumnPresenter.new measure: measure_with_teacher_survey_items, school:, academic_years:,
                                         position: 0
  end

  let(:all_data_presenter) do
    GroupedBarColumnPresenter.new measure: measure_composed_of_student_and_teacher_items, school:, academic_years:,
                                  position: 0
  end

  before do
    create(:respondent, school:, academic_year:, total_students: 1, total_teachers: 1)
    create(:survey, form: :normal, school:, academic_year:)
    create(:survey, form: :normal, school:, academic_year: another_academic_year)
  end

  shared_examples_for 'measure_name' do
    it 'returns the measure name' do
      expect(student_presenter.measure_name).to eq 'Student measure'
    end
  end

  shared_examples_for 'column_midpoint' do
    it 'return an x position centered in the width of the column' do
      expect(student_presenter.column_midpoint).to eq 29
    end
  end

  shared_examples_for 'bar_color' do
    it 'returns the correct color' do
      expect(student_presenter.bars[year_index].color).to eq colors[year_index]
    end
  end

  shared_examples_for 'y_offset' do
    it 'bar will be based on the approval low benchmark boundary' do
      expect(student_presenter.bars[year_index].y_offset).to be_within(0.01).of(34)
    end
  end

  context 'for a grouped column presenter with both student and teacher responses' do
    context 'with a single year'
    before do
      create(:survey_item_response,
             survey_item: student_survey_item_for_composite_measure,
             school:,
             academic_year:,
             likert_score: 4)
      create(:survey_item_response,
             survey_item: student_survey_item_for_composite_measure, school:,
             academic_year:,
             likert_score: 5)
    end

    it 'returns a score that is an average of the likert scores ' do
      expect(all_data_presenter.score(0).average).to eq 4.5
      expect(all_data_presenter.score(1).average).to eq nil
      expect(all_data_presenter.academic_years[0].range).to be academic_year.range
      expect(all_data_presenter.academic_years[1].range).to be another_academic_year.range
    end
    context 'when more than one year exists' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item_for_composite_measure, school:,
                                       academic_year: another_academic_year, likert_score: 5)
        create(:survey_item_response,  survey_item: student_survey_item_for_composite_measure, school:,
                                       academic_year: another_academic_year, likert_score: 3)
      end
      it 'returns independent scores for each year of data' do
        expect(all_data_presenter.score(0).average).to eq 4.5
        expect(all_data_presenter.score(1).average).to eq 4
      end
    end
  end

  context 'when a measure is based on student survey items' do
    context 'when there is insufficient data to show a score' do
      it_behaves_like 'measure_name'
      it_behaves_like 'column_midpoint'

      it 'returns an emtpy set of bars' do
        expect(student_presenter.bars).to eq []
      end

      it 'returns an emty score' do
        expect(student_presenter.score(year_index).average).to eq nil
      end

      it 'shows the irrelevancy message ' do
        expect(student_presenter.show_irrelevancy_message?).to eq true
      end

      it 'shows the insufficient data message' do
        expect(student_presenter.show_insufficient_data_message?).to eq true
      end
    end

    context 'when the score is in the Ideal zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 5)
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 4)
      end

      it_behaves_like 'measure_name'
      it_behaves_like 'column_midpoint'
      it_behaves_like 'bar_color'

      it 'returns a bar width equal to the approval zone width plus the proportionate ideal zone height' do
        expect(student_presenter.bars[year_index].bar_height_percentage).to be_within(0.01).of(17)
      end

      it 'returns a y_offset equal to the ' do
        expect(student_presenter.bars[0].y_offset).to be_within(0.01).of(17)
      end

      it 'returns a text representation of the type of survey the bars are based on' do
        expect(student_presenter.basis).to eq 'student'
      end

      it 'returns only bars that have a numeric score' do
        expect(student_presenter.bars.count).to be 1
      end

      it 'returns an explanatory bar label' do
        expect(student_presenter.label).to eq 'All Students'
      end

      it 'does not show a message that the data source is irrelevant for this measure' do
        expect(student_presenter.show_irrelevancy_message?).to be false
      end

      it 'does not show a message about insufficient responses' do
        expect(student_presenter.show_insufficient_data_message?).to be false
      end

      context 'when there is more than one years worth of data to show' do
        before do
          create(:survey_item_response,  survey_item: student_survey_item, school:,
                                         academic_year: another_academic_year, likert_score: 3)
          create(:survey_item_response,  survey_item: student_survey_item, school:,
                                         academic_year: another_academic_year, likert_score: 4)
        end

        it 'returns only bars that have a numeric score' do
          expect(student_presenter.bars.count).to be 2
        end
      end
    end

    context 'when the score is in the Approval zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 4)
      end

      it_behaves_like 'measure_name'
      it_behaves_like 'column_midpoint'
      it_behaves_like 'bar_color'
      # it_behaves_like 'y_offset'

      context 'and the score is right at the approval low benchmark' do
        it "where bar would normally have a height of 0, we inflate the height to be at least the minimum bar height of #{AnalyzeBarPresenter::MINIMUM_BAR_HEIGHT}" do
          expect(student_presenter.bars[year_index].bar_height_percentage).to be_within(0.01).of(AnalyzeBarPresenter::MINIMUM_BAR_HEIGHT)
        end

        it "where the bar would normally start at the approval low benchmark, it shifts up to accomodate it being grown to the minimum bar height of #{AnalyzeBarPresenter::MINIMUM_BAR_HEIGHT}" do
          expect(student_presenter.bars[year_index].y_offset).to be_within(0.01).of(analyze_zone_height * 2 - AnalyzeBarPresenter::MINIMUM_BAR_HEIGHT)
        end
      end
    end
    context 'when the score is in the Growth zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 3)
      end

      it_behaves_like 'measure_name'
      it_behaves_like 'column_midpoint'
      it_behaves_like 'bar_color'
      it_behaves_like 'y_offset'

      it 'returns a bar width equal to the proportionate growth zone width' do
        expect(student_presenter.bars[year_index].bar_height_percentage).to be_within(0.01).of(17)
      end

      context 'when the score is less than 5 percent away from the approval low benchmark line' do
        before do
          create_list(:survey_item_response, 40, survey_item: student_survey_item, school:,
                                                 academic_year:, likert_score: 4)
        end

        it "it rounds to the the minimum bar height of #{AnalyzeBarPresenter::MINIMUM_BAR_HEIGHT} " do
          expect(student_presenter.bars[year_index].bar_height_percentage).to be_within(0.01).of(AnalyzeBarPresenter::MINIMUM_BAR_HEIGHT)
        end
      end
    end

    context 'when the score is in the Watch zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 2)
      end

      it_behaves_like 'measure_name'
      it_behaves_like 'column_midpoint'
      it_behaves_like 'bar_color'
      it_behaves_like 'y_offset'

      it 'returns a bar width equal to the proportionate watch zone width plus the growth zone width' do
        expect(student_presenter.bars[year_index].bar_height_percentage).to eq 34
      end
    end
    context 'when the score is in the Warning zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 1)
      end

      it_behaves_like 'measure_name'
      it_behaves_like 'column_midpoint'
      it_behaves_like 'bar_color'
      it_behaves_like 'y_offset'

      it 'returns a bar width equal to the proportionate warning zone width plus the watch & growth zone widths' do
        expect(student_presenter.bars[year_index].bar_height_percentage).to eq 51
      end
    end
  end

  context 'when the measure is based on teacher survey items' do
    context 'when there are insufficient responses to calculate a score' do
      it 'indicates it should show the insufficient data message' do
        expect(teacher_presenter.show_insufficient_data_message?).to eq true
      end
    end
    context 'when there are enough responses to calculate a score' do
      before do
        create(:survey_item_response,  survey_item: teacher_survey_item, school:,
                                       academic_year:)
      end

      it 'indicates it should show the insufficient data message' do
        expect(teacher_presenter.show_insufficient_data_message?).to eq false
      end
    end
  end
end
