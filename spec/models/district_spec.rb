require 'rails_helper'

RSpec.describe District, type: :model do
  let(:district1) { District.create(name: 'District one', state_id: 32) }
  let(:district2) { District.new(name: 'District two', state_id: 32) }

  context "when saving or creating" do
    it 'should return a slug' do
      expect(district1.slug).to eq 'district-one'

      district2.save
      expect(district2.slug).to eq 'district-two'

      first_district = District.find_by_slug('district-one')
      expect(first_district.slug).to eq 'district-one'
    end
  end
end

