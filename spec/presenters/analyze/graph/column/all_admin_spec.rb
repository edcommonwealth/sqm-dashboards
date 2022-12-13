require 'rails_helper'
include Analyze::Graph::Column

describe AllAdmin do
  let(:measure_without_admin) { create(:measure) }
  let(:measure_with_admin) { create(:measure, :with_admin_data_items) }
  let(:school) { create(:school) }
  let(:academic_years) { [create(:academic_year)] }
  let(:position) { 1 }
  let(:number_of_columns) { 1 }

  context '.show_irrelevancy_message?' do
    it 'returns true when the measure does NOT include admin data items' do
      expect(AllAdmin.new(measure: measure_without_admin, school:, academic_years:, position:,
                          number_of_columns:).show_irrelevancy_message?).to eq true
    end

    it 'returns false when the measure includes admin data items' do
      expect(AllAdmin.new(measure: measure_with_admin, school:, academic_years:, position:,
                          number_of_columns:).show_irrelevancy_message?).to eq false
    end
  end

  context '.show_insufficient_data_message?' do
    context 'when the measure DOES NOT include admin data items' do
      it 'returns true ' do
        expect(AllAdmin.new(measure: measure_without_admin, school:, academic_years:, position:,
                            number_of_columns:).show_insufficient_data_message?).to eq true
      end

      it 'returns true when the measure does include admin data items but there are not values assigned to the admin' do
        expect(AllAdmin.new(measure: measure_with_admin, school:, academic_years:, position:,
                            number_of_columns:).show_insufficient_data_message?).to eq true
      end
    end

    context 'when the measure Does include admin data items' do
      it 'and has at least one value to show, it will return false' do
        admin_data_item = measure_with_admin.scales.first.admin_data_items.first
        create(:admin_data_value, admin_data_item:, school:, academic_year: academic_years.first)

        expect(AllAdmin.new(measure: measure_with_admin, school:, academic_years:, position:,
                            number_of_columns:).show_insufficient_data_message?).to eq false
      end
    end
  end
end
