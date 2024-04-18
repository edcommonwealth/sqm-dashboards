require "rails_helper"

describe EnrollmentLoader do
  let(:path_to_enrollment_data) { Rails.root.join("spec", "fixtures", "sample_enrollment_data.csv") }
  let(:ay_2021_22) { create(:academic_year, range: "2021-22") }
  let(:ay_2022_23) { create(:academic_year, range: "2022-23") }
  let(:ay_2023_24) { create(:academic_year, range: "2023-24") }
  let(:ay_2024_25_fall) { create(:academic_year, range: "2024-25 Fall") }
  let(:ay_2024_25_spring) { create(:academic_year, range: "2024-25 Spring") }

  let(:attleboro) { create(:school, name: "Attleboro", dese_id: 160_505) }
  let(:beachmont) { create(:school, name: "Beachmont", dese_id: 2_480_013) }
  let(:winchester) { create(:school, name: "Winchester", dese_id: 3_440_505) }
  before :each do
    ay_2021_22
    ay_2022_23
    ay_2023_24
    ay_2024_25_fall
    ay_2024_25_spring
    attleboro
    beachmont
    winchester
    EnrollmentLoader.load_data filepath: path_to_enrollment_data
  end

  context "self.load_data" do
    it "loads the correct enrollment numbers" do
      academic_year = ay_2022_23
      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 506
      # expect(Respondent.find_by(school: attleboro, academic_year:).total_students).to eq 1844

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 34
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 64
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 58
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 336

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 361
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 331
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 339
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 352
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 1383

      academic_year = ay_2021_22
      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 10
      expect(Respondent.find_by(school: attleboro, academic_year:).total_students).to eq 150
      # expect(Respondent.find_by(school: attleboro, academic_year:).total_students).to eq 1844

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 10
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 10
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 10
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 150

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 150
    end

    it "does not load numbers for years outside the file given" do
      academic_year = ay_2023_24
      expect(Respondent.find_by(school: attleboro, academic_year:)).to eq nil

      expect(Respondent.find_by(school: beachmont, academic_year:)).to eq nil
      expect(Respondent.find_by(school: beachmont, academic_year:)).to eq nil
      expect(Respondent.find_by(school: beachmont, academic_year:)).to eq nil
      expect(Respondent.find_by(school: beachmont, academic_year:)).to eq nil

      expect(Respondent.find_by(school: winchester, academic_year:)).to eq nil
      expect(Respondent.find_by(school: winchester, academic_year:)).to eq nil
      expect(Respondent.find_by(school: winchester, academic_year:)).to eq nil
      expect(Respondent.find_by(school: winchester, academic_year:)).to eq nil
      expect(Respondent.find_by(school: winchester, academic_year:)).to eq nil
    end
  end

  context "self.clone_previous_year_data" do
    before do
      EnrollmentLoader.clone_previous_year_data
    end

    it "populates empty data with last known enrollment numbers" do
      # "2023-24"
      academic_year = ay_2023_24
      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 506

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 34
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 64
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 58
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 336

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 361
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 331
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 339
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 352
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 1383

      # "2024-25 Fall"
      academic_year = ay_2024_25_fall

      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 506

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 34
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 64
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 58
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 336

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 361
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 331
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 339
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 352
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 1383

      # "2024-25 Spring"
      academic_year = ay_2024_25_spring

      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 506

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 34
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 64
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 58
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 336

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 361
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 331
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 339
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 352
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 1383

      # Anything that already has numbers from the csv files stays the same
      academic_year = ay_2021_22
      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 10
      expect(Respondent.find_by(school: attleboro, academic_year:).total_students).to eq 150

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 10
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 10
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 10
      expect(Respondent.find_by(school: beachmont, academic_year:).total_students).to eq 150

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 10
      expect(Respondent.find_by(school: winchester, academic_year:).total_students).to eq 150
    end
  end
end
