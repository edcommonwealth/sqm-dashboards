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
          Summary.new('a-exp-i1', 'Percentage teachers with 5+ years of experience', true),
          Summary.new('a-exp-i2', 'Percentage teachers National Board certified', false),
          Summary.new('a-exp-i3', 'Percentage teachers teaching in area of licensure', false)
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
          Summary.new('a-exp-i1', 'Percentage teachers with 5+ years of experience', false),
          Summary.new('a-exp-i2', 'Percentage teachers National Board certified', false),
          Summary.new('a-exp-i3', 'Percentage teachers teaching in area of licensure', false)
        ]
      end
    end
  end
end
