require 'rails_helper'

describe AdminDataPresenter do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }

  let(:measure_1A_i) { create(:measure, measure_id: '1A-i') }
  let(:scale_1) { create(:admin_scale, measure: measure_1A_i) }
  let(:admin_data_item_1) do
    create(:admin_data_item, admin_data_item_id: 'a-exp-i1', scale: scale_1,
                             description: 'Percentage teachers with 5+ years of experience')
  end
  let(:admin_data_item_2) do
    create(:admin_data_item, admin_data_item_id: 'a-exp-i2', scale: scale_1,
                             description: 'Percentage teachers National Board certified')
  end
  let(:admin_data_item_3) do
    create(:admin_data_item, admin_data_item_id: 'a-exp-i3', scale: scale_1,
                             description: 'Percentage teachers teaching in area of licensure')
  end

  let(:measure_1A_iii) { create(:measure, measure_id: '1B-i') }
  let(:scale_2) { create(:admin_scale, measure: measure_1A_iii) }
  let(:admin_data_item_4) do
    create(:admin_data_item, admin_data_item_id: 'a-pcom-i1', scale: scale_2,
                             description: 'Percent teacher returning (excluding retirement)')
  end
  let(:admin_data_item_5) do
    create(:admin_data_item, admin_data_item_id: 'a-pcom-i2', scale: scale_2,
                             description: 'Percent teachers with 10+ days absent')
  end

  before :each do
    scale_1
    scale_2
    admin_data_item_1
    admin_data_item_2
    admin_data_item_3
    admin_data_item_4
    admin_data_item_5
  end

  describe '#item_description' do
    context 'When the presenter is based on measure 1A-1' do
      it 'returns a list of survey prompts for teacher survey items' do
        expect(AdminDataPresenter.new(measure_id: measure_1A_i.measure_id, admin_data_items: measure_1A_i.admin_data_items,
                                      has_sufficient_data: true, school:, academic_year:).item_descriptions).to eq [
                                        'Percentage teachers with 5+ years of experience', 'Percentage teachers National Board certified', 'Percentage teachers teaching in area of licensure'
                                      ]
      end
      context 'When the measure is missing all admin data values' do
        it 'if it lacks sufficient data, it shows a warning ' do
          expect(AdminDataPresenter.new(measure_id: measure_1A_i.measure_id, admin_data_items: measure_1A_i.admin_data_items,
                                        has_sufficient_data: false, school:, academic_year:).sufficient_data?).to eq false
        end
      end

      context 'When the measure has at least one admin data value' do
        it 'if it lacks sufficient data, it doesnt show a warning ' do
          expect(AdminDataPresenter.new(measure_id: measure_1A_i.measure_id, admin_data_items: measure_1A_i.admin_data_items,
                                        has_sufficient_data: true, school:, academic_year:).sufficient_data?).to eq true
        end
      end
    end

    context 'When the presenter is based on measure 1A-iii' do
      it 'returns a message hiding the actual prompts.  Instead it presents a message telling the user they can ask for more information' do
        expect(AdminDataPresenter.new(measure_id: measure_1A_iii.measure_id, admin_data_items: measure_1A_iii.admin_data_items,
                                      has_sufficient_data: true, school:, academic_year:).item_descriptions).to eq [
                                        'Percent teacher returning (excluding retirement)', 'Percent teachers with 10+ days absent'
                                      ]
      end
    end
  end

  describe '#descriptions_and_availibility' do
    context 'when there are any matching values for admin data items' do
      before do
        admin_data_item = measure_1A_i.admin_data_items.first
        create(:admin_data_value, admin_data_item:, school:, academic_year:)
      end
      it 'returns a list of admin data items and whether there is a matching value' do
        expect(
          AdminDataPresenter.new(
            measure_id: measure_1A_i.measure_id, admin_data_items: measure_1A_i.admin_data_items, has_sufficient_data: true, school:, academic_year:
          ).descriptions_and_availability
        ).to eq [
          DataAvailability.new('a-exp-i1', 'Percentage teachers with 5+ years of experience', true),
          DataAvailability.new('a-exp-i2', 'Percentage teachers National Board certified', false),
          DataAvailability.new('a-exp-i3', 'Percentage teachers teaching in area of licensure', false)
        ]
      end
    end
    context 'when there are NO matching values for admin data items' do
      it 'returns a list of admin data items and whether there is a matching value' do
        expect(
          AdminDataPresenter.new(
            measure_id: measure_1A_i.measure_id, admin_data_items: measure_1A_i.admin_data_items, has_sufficient_data: true, school:, academic_year:
          ).descriptions_and_availability
        ).to eq [
          DataAvailability.new('a-exp-i1', 'Percentage teachers with 5+ years of experience', false),
          DataAvailability.new('a-exp-i2', 'Percentage teachers National Board certified', false),
          DataAvailability.new('a-exp-i3', 'Percentage teachers teaching in area of licensure', false)
        ]
      end
    end
  end
end
