require 'rails_helper'

RSpec.describe DisaggregationRow do
  let(:headers) do
    ['District', 'Academic Year', 'LASID', 'HispanicLatino', 'Race', 'Gender', 'SpecialEdStatus', 'In 504 Plan',
     'LowIncome', 'EL Student First Year']
  end

  context '.district' do
    context 'when the column heading is any upper or lowercase variant of the word district' do
      it 'returns the correct value for district' do
        row = { 'District' => 'Maynard Public Schools' }
        expect(DisaggregationRow.new(row:, headers:).district).to eq 'Maynard Public Schools'

        headers = ['dISTRICT']
        headers in [district]
        row = { district => 'Maynard Public Schools' }
        expect(DisaggregationRow.new(row:, headers:).district).to eq 'Maynard Public Schools'
      end
    end
  end

  context '.academic_year' do
    context 'when the column heading is any upper or lowercase variant of the words academic year' do
      it 'returns the correct value for district' do
        row = { 'Academic Year' => '2022-23' }
        expect(DisaggregationRow.new(row:, headers:).academic_year).to eq '2022-23'

        headers = ['aCADEMIC yEAR']
        headers in [academic_year]
        row = { academic_year => '2022-23' }
        expect(DisaggregationRow.new(row:, headers:).academic_year).to eq '2022-23'

        headers = ['AcademicYear']
        headers in [academic_year]
        row = { academic_year => '2022-23' }
        expect(DisaggregationRow.new(row:, headers:).academic_year).to eq '2022-23'
      end
    end
  end

  context '.income' do
    context 'when the column heading is any upper or lowercase variant of the words low income' do
      it 'returns the correct value for low_income' do
        row = { 'LowIncome' => 'Free Lunch' }
        expect(DisaggregationRow.new(row:, headers:).income).to eq 'Free Lunch'

        headers = ['Low income']
        headers in [income]
        row = { income => 'Free Lunch' }
        expect(DisaggregationRow.new(row:, headers:).income).to eq 'Free Lunch'

        headers = ['LoW InCOme']
        headers in [income]
        row = { income => 'Free Lunch' }
        expect(DisaggregationRow.new(row:, headers:).income).to eq 'Free Lunch'
      end
    end
  end

  context '.lasid' do
    context 'when the column heading is any upper or lowercase variant of the words lasid' do
      it 'returns the correct value for lasid' do
        row = { 'LASID' => '2366' }
        expect(DisaggregationRow.new(row:, headers:).lasid).to eq '2366'

        headers = ['LaSiD']
        headers in [lasid]
        row = { lasid => '2366' }
        expect(DisaggregationRow.new(row:, headers:).lasid).to eq '2366'
      end
    end
  end
end
