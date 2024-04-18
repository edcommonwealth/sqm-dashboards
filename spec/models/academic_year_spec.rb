require "rails_helper"

RSpec.describe AcademicYear, type: :model do
  describe ".find_by_date" do
    context "when an academic year is not split into seasons" do
      before do
        create(:academic_year, range: "2022-23")
        create(:academic_year, range: "2023-24")
        create(:academic_year, range: "2024-25")
      end

      it "parses 2022-23 as the range" do
        ranges = AcademicYear.by_range.keys
        date = Date.parse("2022-12-12")
        expect(AcademicYear.range_from_date(date, ranges)).to eq "2022-23"
      end
    end

    context "when an academic year is split into seasons" do
      before do
        create(:academic_year, range: "2021-22 Fall")
        create(:academic_year, range: "2021-22 Spring")
        create(:academic_year, range: "2022-23")
        create(:academic_year, range: "2023-24 Fall")
        create(:academic_year, range: "2023-24 Spring")
        create(:academic_year, range: "2024-25")
      end

      context "and the range falls on an academic year without seasons" do
        it "returns a range without the season added" do
          ranges = AcademicYear.by_range.keys

          # Start of 2022-23
          date = Date.parse("2022-7-1")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2022-23"

          # End of 2022-23
          date = Date.parse("2023-6-30")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2022-23"

          # Start of 2024-25
          date = Date.parse("2024-7-1")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2024-25"

          # End of 2024-25
          date = Date.parse("2025-6-30")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2024-25"
        end
      end
      context "and the range falls within an academic year with seasons" do
        it "returns a range with the season added using the cutoff date of the last Sunday in February" do
          ranges = AcademicYear.by_range.keys

          # Start of Fall 2023-24
          date = Date.parse("2023-7-1")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2023-24 Fall"

          # End of Fall 2023-24
          date = Date.parse("2024-2-24")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2023-24 Fall"

          # Start of Spring 2023-24
          date = Date.parse("2024-2-25")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2023-24 Spring"

          # End of Spring 2023-24
          date = Date.parse("2024-6-30")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2023-24 Spring"

          # Start of Fall 2021-22
          date = Date.parse("2021-7-1")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2021-22 Fall"

          # End of Fall 2021-22
          date = Date.parse("2022-2-26")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2021-22 Fall"

          # Start of Spring 2021-22
          date = Date.parse("2022-2-27")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2021-22 Spring"

          # End of Spring 2021-22
          date = Date.parse("2022-6-30")
          expect(AcademicYear.range_from_date(date, ranges)).to eq "2021-22 Spring"
        end
      end
    end
  end

  describe ".range_without_season" do
    context "when the range doesn't have a season " do
      before do
        create(:academic_year, range: "2022-23")
        create(:academic_year, range: "2023-24")
        create(:academic_year, range: "2024-25")
      end

      it "parses 2022-23 as the range" do
        ay = AcademicYear.find_by_range "2022-23"
        expect(ay.range_without_season).to eq "2022-23"
      end
    end

    context "when an academic year is split into seasons" do
      before do
        create(:academic_year, range: "2023-24 Fall")
        create(:academic_year, range: "2023-24 Spring")
      end

      it "removes the season from the range" do
        ay = AcademicYear.find_by_range "2023-24 Fall"
        expect(ay.range_without_season).to eq "2023-24"
      end
    end
  end
end
