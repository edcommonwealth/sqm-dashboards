require "rails_helper"

describe StaffingLoader do
  let(:path_to_staffing_data) { Rails.root.join("spec", "fixtures", "sample_staffing_data.csv") }
  let(:ay_2020_21) { create(:academic_year, range: "2020-21") }
  let(:ay_2021_22) { create(:academic_year, range: "2021-22") }
  let(:ay_2022_23) { create(:academic_year, range: "2022-23") }
  let(:ay_2023_24_fall) { create(:academic_year, range: "2023-24 Fall") }
  let(:ay_2023_24_spring) { create(:academic_year, range: "2023-24 Spring") }
  let(:attleboro) { create(:school, name: "Attleboro", dese_id: 160_505) }
  let(:beachmont) { create(:school, name: "Beachmont", dese_id: 2_480_013) }
  let(:winchester) { create(:school, name: "Winchester", dese_id: 3_440_505) }

  before :each do
    ay_2020_21
    ay_2021_22
    ay_2022_23
    ay_2023_24_fall
    ay_2023_24_spring
    attleboro
    beachmont
    winchester
  end

  context "self.load_data" do
    before do
      StaffingLoader.load_data filepath: path_to_staffing_data
    end
    it "loads the correct staffing numbers" do
      academic_year = ay_2021_22
      expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 197.5

      expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 56.4

      expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 149.8
    end
  end

  context "self.clone_previous_year_data" do
    before do
      StaffingLoader.load_data filepath: path_to_staffing_data
      StaffingLoader.clone_previous_year_data
    end

    it "fills in empty staffing numbers with the previous years data" do
      academic_year = ay_2022_23
      expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 197.5

      expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 56.4

      expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 149.8

      academic_year = ay_2023_24_fall
      expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 197.5

      expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 56.4

      expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 149.8

      academic_year = ay_2023_24_spring
      expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 197.5

      expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 56.4

      expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 149.8

      # Does not touch existing numbers

      academic_year = ay_2020_21
      expect(Respondent.find_by(school: attleboro, academic_year:).total_teachers).to eq 100

      expect(Respondent.find_by(school: beachmont, academic_year:).total_teachers).to eq 100

      expect(Respondent.find_by(school: winchester, academic_year:).total_teachers).to eq 100
    end
  end
end
