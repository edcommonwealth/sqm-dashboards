require "rails_helper"
RSpec.describe Report::Subcategory, type: :model do
  let(:school) { create(:school, name: "Milford High", slug: "milford-high") }
  let(:academic_year) { create(:academic_year, range: "2018-2019") }
  let(:subcategory) { create(:subcategory, subcategory_id: "1A") }
  let(:respondent) { create(:respondent, school:, academic_year:) }
  before :each do
    school
    academic_year
    subcategory
    respondent
  end
  let(:measure) { create(:measure, subcategory:) }
  let(:scale) { create(:scale, measure:) }
  let(:survey_item) { create(:student_survey_item, scale:) }

  context "when creating a report for a subcategory" do
    before :each do
      create_list(:survey_item_response, 10, survey_item:, school:, academic_year:)
    end

    it "creates a report for subcategories with the correct headers" do
      report = Report::Subcategory.create_report
      csv = CSV.parse(report, headers: true)
      headers = csv.headers
      expect(headers).to be_a(Array)
      expect(headers).to eq(["District", "School", "School Code", "Academic Year", "Recorded Date Range", "Grades", "Subcategory", "Student Score",
                             "Student Zone", "Teacher Score", "Teacher Zone", "Admin Score", "Admin Zone", "All Score (Average)", "All Score Zone"])
    end

    it "Adds information about the first school and first academic year to the report" do
      report = Report::Subcategory.create_report
      csv = CSV.parse(report, headers: true)
      csv.first in [district, school_name, school_code, academic_year, recorded_date_range, grades, subcategory_id, *]
      expect(school_name).to eq("Milford High")
      expect(academic_year).to eq("2018-2019")
      expect(subcategory_id).to eq("1A")
    end
  end
  describe ".create_report" do
    before do
      allow(Report::Subcategory).to receive(:write_csv)
    end

    it "generates a CSV report" do
      expect(FileUtils).to receive(:mkdir_p).with(Rails.root.join("tmp", "reports"))

      Report::Subcategory.create_report

      expect(Report::Subcategory).to have_received(:write_csv)
    end
  end
  describe ".write_csv" do
    it "writes the data to a CSV file" do
      data = [["School", "Academic Year", "Subcategory"], ["School A", "2022-2023", "Category A"]]

      csv = CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end

      filepath = Rails.root.join("tmp", "spec", "reports", "subcategories.csv")

      FileUtils.mkdir_p Rails.root.join("tmp", "spec", "reports")
      Report::Subcategory.write_csv(csv:, filepath:)

      csv_data = File.read(filepath)
      expect(csv_data).to include("School,Academic Year,Subcategory")
      expect(csv_data).to include("School A,2022-2023,Category A")
    end
  end

  describe ".student_score" do
    let(:response_rate) { create(:response_rate, subcategory:, school:, academic_year:) }
    let(:row) { [response_rate, subcategory, school, academic_year] }

    it "returns student score if response rate meets student threshold" do
      allow(subcategory).to receive(:student_score).and_return(80)
      allow(response_rate).to receive(:meets_student_threshold?).and_return(true)

      score = Report::Subcategory.student_score(row:)

      expect(score).to eq(80)
    end

    it 'returns "N/A" if response rate does not meet student threshold' do
      allow(response_rate).to receive(:meets_student_threshold?).and_return(false)

      score = Report::Subcategory.student_score(row:)

      expect(score).to eq("N/A")
    end
  end
end
