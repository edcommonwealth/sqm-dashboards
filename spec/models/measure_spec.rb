require 'rails_helper'

RSpec.describe Measure, type: :model do
  let(:measure) { create(:measure) }
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

  context 'when a measure includes only one admin data item' do
    before do
      create(:admin_data_item, measure: measure,
                               watch_low_benchmark: admin_watch_low_benchmark,
                               growth_low_benchmark: admin_growth_low_benchmark,
                               approval_low_benchmark: admin_approval_low_benchmark,
                               ideal_low_benchmark: admin_ideal_low_benchmark)
    end
    it 'returns a watch low benchmark equal to the admin data item watch low benchmark' do
      expect(measure.watch_low_benchmark).to be 2.0
    end
  end

  context 'when a measure includes only student survey items' do
    before do
      create(:student_survey_item, measure: measure,
                                   watch_low_benchmark: student_watch_low_benchmark,
                                   growth_low_benchmark: student_growth_low_benchmark,
                                   approval_low_benchmark: student_approval_low_benchmark,
                                   ideal_low_benchmark: student_ideal_low_benchmark)
    end
    it 'returns a watch low benchmark equal to the student survey item watch low benchmark ' do
      expect(measure.watch_low_benchmark).to be 1.5
    end
  end

  context 'when a measure includes only teacher survey items' do
    before do
      create(:teacher_survey_item, measure: measure,
                                   watch_low_benchmark: teacher_watch_low_benchmark,
                                   growth_low_benchmark: teacher_growth_low_benchmark,
                                   approval_low_benchmark: teacher_approval_low_benchmark,
                                   ideal_low_benchmark: teacher_ideal_low_benchmark)
    end
    it 'returns a watch low benchmark equal to the teacher survey item watch low benchmark ' do
      expect(measure.watch_low_benchmark).to be 1.2
    end
  end

  context 'when a measure includes admin data and student survey items' do
    before do
      create_list(:admin_data_item, 3, measure: measure,
                                       watch_low_benchmark: admin_watch_low_benchmark,
                                       growth_low_benchmark: admin_growth_low_benchmark,
                                       approval_low_benchmark: admin_approval_low_benchmark,
                                       ideal_low_benchmark: admin_ideal_low_benchmark)

      create(:student_survey_item, measure: measure,
                                   watch_low_benchmark: student_watch_low_benchmark,
                                   growth_low_benchmark: student_growth_low_benchmark,
                                   approval_low_benchmark: student_approval_low_benchmark,
                                   ideal_low_benchmark: student_ideal_low_benchmark)
    end

    it 'returns the average of admin and student benchmarks where each admin data item has a weight of 1 and student survey items all together have a weight of 1' do
      # (2*3 + 1.5)/4
      expect(measure.watch_low_benchmark).to be 1.875
    end
  end

  context 'when a measure includes admin data and teacher survey items' do
    before do
      create_list(:admin_data_item, 3, measure: measure,
                                       watch_low_benchmark: admin_watch_low_benchmark,
                                       growth_low_benchmark: admin_growth_low_benchmark,
                                       approval_low_benchmark: admin_approval_low_benchmark,
                                       ideal_low_benchmark: admin_ideal_low_benchmark)

      create(:teacher_survey_item, measure: measure,
                                   watch_low_benchmark: teacher_watch_low_benchmark,
                                   growth_low_benchmark: teacher_growth_low_benchmark,
                                   approval_low_benchmark: teacher_approval_low_benchmark,
                                   ideal_low_benchmark: teacher_ideal_low_benchmark)
    end

    it 'returns the average of admin and teacher benchmarks where each admin data item has a weight of 1 and teacher survey items all together have a weight of 1' do
      # (2*3 + 1.2)/4
      expect(measure.watch_low_benchmark).to be 1.8
    end
  end

  context 'when a measure includes student and teacher survey items' do
    before do
      create_list(:student_survey_item, 3, measure: measure,
                                           watch_low_benchmark: student_watch_low_benchmark,
                                           growth_low_benchmark: student_growth_low_benchmark,
                                           approval_low_benchmark: student_approval_low_benchmark,
                                           ideal_low_benchmark: student_ideal_low_benchmark)

      create_list(:teacher_survey_item, 3, measure: measure,
                                           watch_low_benchmark: teacher_watch_low_benchmark,
                                           growth_low_benchmark: teacher_growth_low_benchmark,
                                           approval_low_benchmark: teacher_approval_low_benchmark,
                                           ideal_low_benchmark: teacher_ideal_low_benchmark)
    end

    it 'returns the average of student and teacher benchmarks where teacher survey items all together have a weight of 1 and all student survey items have a weight of 1' do
      # (1.2+ 1.5)/2
      expect(measure.watch_low_benchmark).to be 1.35
    end
  end

  context 'when a measure includes admin data and student and teacher survey items' do
    before do
      create_list(:admin_data_item, 3, measure: measure,
                                       watch_low_benchmark: admin_watch_low_benchmark,
                                       growth_low_benchmark: admin_growth_low_benchmark,
                                       approval_low_benchmark: admin_approval_low_benchmark,
                                       ideal_low_benchmark: admin_ideal_low_benchmark)
      create_list(:student_survey_item, 3, measure: measure,
                                           watch_low_benchmark: student_watch_low_benchmark,
                                           growth_low_benchmark: student_growth_low_benchmark,
                                           approval_low_benchmark: student_approval_low_benchmark,
                                           ideal_low_benchmark: student_ideal_low_benchmark)

      create_list(:teacher_survey_item, 3, measure: measure,
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
  end
end
