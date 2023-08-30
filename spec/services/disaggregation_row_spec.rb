require "rails_helper"

RSpec.describe DisaggregationRow do
  let(:headers) do
    ["District", "Academic Year", "LASID", "HispanicLatino", "Race", "Gender", "SpecialEdStatus", "In 504 Plan",
     "LowIncome", "EL Student First Year"]
  end

  context ".district" do
    context "when the column heading is any upper or lowercase variant of the word district" do
      it "returns the correct value for district" do
        row = { "District" => "Maynard Public Schools" }
        expect(DisaggregationRow.new(row:, headers:).district).to eq "Maynard Public Schools"

        headers = ["dISTRICT"]
        headers in [district]
        row = { district => "Maynard Public Schools" }
        expect(DisaggregationRow.new(row:, headers:).district).to eq "Maynard Public Schools"
      end
    end
  end

  context ".academic_year" do
    context "when the column heading is any upper or lowercase variant of the words academic year" do
      it "returns the correct value for district" do
        row = { "Academic Year" => "2022-23" }
        expect(DisaggregationRow.new(row:, headers:).academic_year).to eq "2022-23"

        headers = ["aCADEMIC yEAR"]
        headers in [academic_year]
        row = { academic_year => "2022-23" }
        expect(DisaggregationRow.new(row:, headers:).academic_year).to eq "2022-23"

        headers = ["AcademicYear"]
        headers in [academic_year]
        row = { academic_year => "2022-23" }
        expect(DisaggregationRow.new(row:, headers:).academic_year).to eq "2022-23"
      end
    end
  end

  context ".raw_income" do
    context "when the column heading is any upper or lowercase variant of the words low income" do
      it "returns the correct value for low_income" do
        row = { "LowIncome" => "Free Lunch" }
        expect(DisaggregationRow.new(row:, headers:).raw_income).to eq "Free Lunch"

        headers = ["Low income"]
        headers in [income]
        row = { income => "Free Lunch" }
        expect(DisaggregationRow.new(row:, headers:).raw_income).to eq "Free Lunch"

        headers = ["LoW InCOme"]
        headers in [income]
        row = { income => "Free Lunch" }
        expect(DisaggregationRow.new(row:, headers:).raw_income).to eq "Free Lunch"
      end
    end
  end

  context ".lasid" do
    context "when the column heading is any upper or lowercase variant of the words lasid" do
      it "returns the correct value for lasid" do
        row = { "LASID" => "2366" }
        expect(DisaggregationRow.new(row:, headers:).lasid).to eq "2366"

        headers = ["LaSiD"]
        headers in [lasid]
        row = { lasid => "2366" }
        expect(DisaggregationRow.new(row:, headers:).lasid).to eq "2366"
      end
    end
  end

  context ".ell" do
    context "when the column heading is any upper or lowercase variant of the words 'ELL' or 'El Student First Year'" do
      it "returns the correct value for a student" do
        row = { "EL Student First Year" => "LEP student 1st year" }
        expect(DisaggregationRow.new(row:, headers:).ell).to eq "ELL"

        headers = ["EL Student First Year"]
        headers in [ell]
        row = { ell => "LEP student not 1st year" }
        expect(DisaggregationRow.new(row:, headers:).ell).to eq "ELL"

        headers = ["EL Student First Year"]
        headers in [ell]
        row = { ell => "Does not apply" }
        expect(DisaggregationRow.new(row:, headers:).ell).to eq "Not ELL"

        headers = ["EL Student First Year"]
        headers in [ell]
        row = { ell => "Unknown" }
        expect(DisaggregationRow.new(row:, headers:).ell).to eq "Unknown"

        headers = ["EL Student First Year"]
        headers in [ell]
        row = { ell => "Any other text" }
        expect(DisaggregationRow.new(row:, headers:).ell).to eq "Unknown"

        headers = ["EL Student First Year"]
        headers in [ell]
        row = { ell => "" }
        expect(DisaggregationRow.new(row:, headers:).ell).to eq "Unknown"
      end
    end
  end
end
