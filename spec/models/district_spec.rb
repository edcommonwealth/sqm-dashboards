require 'rails_helper'

RSpec.describe District, type: :model do
  let(:lowell) { create(:district, name: "Lowell public schools") }
  let(:lee) { create(:district, name: "Lee public schools") }
  let(:maynard) { create(:district, name: "Maynard public schools") }

  context '.short_name' do
    it "returns the first word in lowercase of a district's name" do
      expect(lowell.short_name).to eq "lowell"
      expect(lee.short_name).to eq "lee"
      expect(maynard.short_name).to eq "maynard"
    end
  end
end
