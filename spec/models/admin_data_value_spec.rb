# frozen_string_literal: true

require 'rails_helper'
RSpec.describe AdminDataValue, type: :model do
  let(:school) { create(:school) }
  let(:admin_data_item) { create(:admin_data_item) }
  let(:academic_year) { create(:academic_year) }
  context '#value' do
    context 'when the value is in the valid range of greater than zero to five' do
      it 'should return valid values' do
        value = AdminDataValue.create!(likert_score: 1, school:, admin_data_item:, academic_year:)
        expect(value.likert_score).to eq(1)
        value = AdminDataValue.create!(likert_score: 2, school:, admin_data_item:, academic_year:)
        expect(value.likert_score).to eq(2)
        value = AdminDataValue.create!(likert_score: 5, school:, admin_data_item:, academic_year:)
        expect(value.likert_score).to eq(5)
      end
    end

    context 'when the value is zero or below  or greater than 5' do
      it 'should not create the value' do
        expect do
          AdminDataValue.create!(likert_score: 0, school:, admin_data_item:,
                                 academic_year:)
        end.to raise_error
        expect do
          AdminDataValue.create!(likert_score: 5.00001, school:, admin_data_item:,
                                 academic_year:)
        end.to raise_error
        expect(AdminDataValue.count).to eq(0)
      end
    end
  end
end
