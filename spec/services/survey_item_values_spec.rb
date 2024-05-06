require "rails_helper"

RSpec.describe SurveyItemValues, type: :model do
  let(:headers) do
    ["StartDate", "EndDate", "Status", "IPAddress", "Progress", "Duration (in seconds)", "Finished", "RecordedDate",
     "ResponseId", "RecipientLastName", "RecipientFirstName", "RecipientEmail", "ExternalReference", "LocationLatitude", "LocationLongitude", "DistributionChannel", "UserLanguage", "District", "School- Lee", "School- Maynard", "LASID", "Grade", "s-emsa-q1", "s-emsa-q2", "s-emsa-q3", "s-tint-q1", "s-tint-q2", "s-tint-q3", "s-tint-q4", "s-tint-q5", "s-acpr-q1", "s-acpr-q2", "s-acpr-q3", "s-acpr-q4", "s-cure-q1", "s-cure-q2", "s-cure-q3", "s-cure-q4", "s-sten-q1", "s-sten-q2", "s-sten-q3", "s-sper-q1", "s-sper-q2", "s-sper-q3", "s-sper-q4", "s-civp-q1", "s-civp-q2", "s-civp-q3", "s-civp-q4", "s-grmi-q1", "s-grmi-q2", "s-grmi-q3", "s-grmi-q4", "s-appa-q1", "s-appa-q2", "s-appa-q3", "s-peff-q1", "s-peff-q2", "s-peff-q3", "s-peff-q4", "s-peff-q5", "s-peff-q6", "s-sbel-q1", "s-sbel-q2", "s-sbel-q3", "s-sbel-q4", "s-sbel-q5", "s-phys-q1", "s-phys-q2", "s-phys-q3", "s-phys-q4", "s-vale-q1", "s-vale-q2", "s-vale-q3", "s-vale-q4", "s-acst-q1", "s-acst-q2", "s-acst-q3", "s-sust-q1", "s-sust-q2", "s-grit-q1", "s-grit-q2", "s-grit-q3", "s-grit-q4", "s-expa-q1", "s-poaf-q1", "s-poaf-q2", "s-poaf-q3", "s-poaf-q4", "s-tint-q1-1", "s-tint-q2-1", "s-tint-q3-1", "s-tint-q4-1", "s-tint-q5-1", "s-acpr-q1-1", "s-acpr-q2-1", "s-acpr-q3-1", "s-acpr-q4-1", "s-peff-q1-1", "s-peff-q2-1", "s-peff-q3-1", "s-peff-q4-1", "s-peff-q5-1", "s-peff-q6-1", "Gender", "Race"]
  end
  let(:genders) do
    create(:gender, qualtrics_code: 1)
    create(:gender, qualtrics_code: 2)
    create(:gender, qualtrics_code: 4)
    create(:gender, qualtrics_code: 99)
    Gender.by_qualtrics_code
  end

  let(:races) do
    create(:race, qualtrics_code: 1)
    create(:race, qualtrics_code: 2)
    create(:race, qualtrics_code: 3)
    create(:race, qualtrics_code: 4)
    create(:race, qualtrics_code: 5)
    create(:race, qualtrics_code: 6)
    create(:race, qualtrics_code: 7)
    create(:race, qualtrics_code: 8)
    create(:race, qualtrics_code: 99)
    create(:race, qualtrics_code: 100)
    Race.by_qualtrics_code
  end

  let(:survey_items) { [] }
  let(:district) { create(:district, name: "Attleboro") }
  let(:attleboro) do
    create(:school, name: "Attleboro", dese_id: 1234, district:)
  end
  let(:attleboro_respondents) do
    create(:respondent, school: attleboro, academic_year: ay_2022_23, nine: 40, ten: 40, eleven: 40, twelve: 40)
  end
  let(:schools) { School.by_dese_id }
  let(:recorded_date) { "2023-04-01T12:12:12" }
  let(:ay_2022_23) do
    create(:academic_year, range: "2022-23")
  end
  let(:academic_years) { AcademicYear.all }

  let(:common_headers) do
    ["Recorded Date", "DeseID", "ResponseID", "Duration (in seconds)", "Gender", "Grade"]
  end

  let(:standard_survey_items) do
    survey_item_ids = %w[s-peff-q1 s-peff-q2 s-peff-q3 s-peff-q4 s-peff-q5 s-peff-q6 s-phys-q1 s-phys-q2 s-phys-q3 s-phys-q4
                         s-emsa-q1 s-emsa-q2 s-emsa-q3 s-sbel-q1 s-sbel-q2 s-sbel-q3 s-sbel-q4 s-sbel-q5 s-tint-q1 s-tint-q2
                         s-tint-q3 s-tint-q4 s-tint-q5 s-vale-q1 s-vale-q2 s-vale-q3 s-vale-q4 s-acpr-q1 s-acpr-q2 s-acpr-q3
                         s-acpr-q4 s-sust-q1 s-sust-q2 s-cure-q1 s-cure-q2 s-cure-q3 s-cure-q4 s-sten-q1 s-sten-q2 s-sten-q3
                         s-sper-q1 s-sper-q2 s-sper-q3 s-sper-q4 s-civp-q1 s-civp-q2 s-civp-q3 s-civp-q4 s-grit-q1 s-grit-q2
                         s-grit-q3 s-grit-q4 s-grmi-q1 s-grmi-q2 s-grmi-q3 s-grmi-q4 s-expa-q1 s-appa-q1 s-appa-q2 s-appa-q3
                         s-acst-q1 s-acst-q2 s-acst-q3 s-poaf-q1 s-poaf-q2 s-poaf-q3 s-poaf-q4]
    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:)
    end
    (survey_item_ids << common_headers).flatten
  end

  let(:short_form_survey_items) do
    survey_item_ids = %w[s-peff-q1 s-peff-q2 s-peff-q3 s-peff-q4 s-peff-q5 s-peff-q6 s-phys-q1 s-phys-q2 s-phys-q3 s-phys-q4
                         s-emsa-q1 s-emsa-q2 s-emsa-q3 s-sbel-q1 s-sbel-q2 s-sbel-q3 s-sbel-q4 s-sbel-q5 s-tint-q1 s-tint-q2
                         s-tint-q3 s-tint-q4 s-tint-q5 s-vale-q1 s-vale-q2 s-vale-q3 s-vale-q4 s-acpr-q1 s-acpr-q2 s-acpr-q3
                         s-acpr-q4 s-sust-q1 s-sust-q2 s-cure-q1 s-cure-q2 s-cure-q3 s-cure-q4 s-sten-q1 s-sten-q2 s-sten-q3
                         s-sper-q1 s-sper-q2 s-sper-q3 s-sper-q4 s-civp-q1 s-civp-q2 s-civp-q3 s-civp-q4 s-grit-q1 s-grit-q2
                         s-grit-q3 s-grit-q4 s-grmi-q1 s-grmi-q2 s-grmi-q3 s-grmi-q4 s-expa-q1 s-appa-q1 s-appa-q2 s-appa-q3
                         s-acst-q1 s-acst-q2 s-acst-q3 s-poaf-q1 s-poaf-q2 s-poaf-q3 s-poaf-q4 s-phys-q1 s-phys-q2 s-phys-q3]
    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:, on_short_form: true)
    end
    (survey_item_ids << common_headers).flatten
  end

  let(:early_education_survey_items) do
    survey_item_ids = %w[s-peff-es1 s-peff-es2 s-peff-es3 s-peff-es4 s-peff-es5 s-peff-es6 s-phys-es1 s-phys-es2 s-phys-es3 s-phys-es4
                         s-emsa-es1 s-emsa-es2 s-emsa-es3 s-sbel-es1 s-sbel-es2 s-sbel-es3 s-sbel-es4 s-sbel-es5 s-tint-es1 s-tint-es2
                         s-tint-es3 s-tint-es4 s-tint-es5 s-vale-es1 s-vale-es2 s-vale-es3 s-vale-es4 s-acpr-es1 s-acpr-es2 s-acpr-es3
                         s-acpr-es4 s-sust-es1 s-sust-es2 s-cure-es1 s-cure-es2 s-cure-es3 s-cure-es4 s-sten-es1 s-sten-es2 s-sten-es3
                         s-sper-es1 s-sper-es2 s-sper-es3 s-sper-es4 s-civp-es1 s-civp-es2 s-civp-es3 s-civp-es4 s-grit-es1 s-grit-es2
                         s-grit-es3 s-grit-es4 s-grmi-es1 s-grmi-es2 s-grmi-es3 s-grmi-es4 s-expa-es1 s-appa-es1 s-appa-es2 s-appa-es3
                         s-acst-es1 s-acst-es2 s-acst-es3 s-poaf-es1 s-poaf-es2 s-poaf-es3 s-poaf-es4 s-phys-es1 s-phys-es2 s-phys-es3]
    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:)
    end
    (survey_item_ids << common_headers).flatten
  end

  let(:teacher_survey_items) do
    survey_item_ids = %w[t-prep-q1 t-prep-q2 t-prep-q3 t-ieff-q1 t-ieff-q2 t-ieff-q3 t-ieff-q4 t-pcom-q1 t-pcom-q2 t-pcom-q3
                         t-pcom-q4 t-pcom-q5 t-inle-q1 t-inle-q2 t-inle-q3 t-prtr-q1 t-prtr-q2 t-prtr-q3 t-coll-q1 t-coll-q2
                         t-coll-q3 t-qupd-q1 t-qupd-q2 t-qupd-q3 t-qupd-q4 t-pvic-q1 t-pvic-q2 t-pvic-q3 t-psup-q1 t-psup-q2
                         t-psup-q3 t-psup-q4 t-acch-q1 t-acch-q2 t-acch-q3 t-reso-q1 t-reso-q2 t-reso-q3 t-reso-q4 t-reso-q5
                         t-sust-q1 t-sust-q2 t-sust-q3 t-sust-q4 t-curv-q1 t-curv-q2 t-curv-q3 t-curv-q4 t-cure-q1 t-cure-q2
                         t-cure-q3 t-cure-q4 t-peng-q1 t-peng-q2 t-peng-q3 t-peng-q4 t-ceng-q1 t-ceng-q2 t-ceng-q3 t-ceng-q4
                         t-sach-q1 t-sach-q2 t-sach-q3 t-psol-q1 t-psol-q2 t-psol-q3 t-expa-q2 t-expa-q3 t-phya-q2 t-phya-q3]

    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:)
    end
    (survey_item_ids << common_headers).flatten
  end

  context ".recorded_date" do
    it "returns the recorded date" do
      row = { "RecordedDate" => "2017-01-01T12:12:121" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.recorded_date).to eq Date.parse("2017-01-01T12:12:12")

      headers = ["Recorded Date"]
      row = { "Recorded Date" => "2017-01-02T12:12:122" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.recorded_date).to eq Date.parse("2017-01-02T12:12:12")
    end
  end

  context ".school" do
    it "returns the school that maps to the dese id provided" do
      attleboro
      headers = ["DeseID"]
      row = { "DeseID" => "1234" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.school).to eq attleboro

      row = { "DeseID" => "1234" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.school).to eq attleboro
    end
  end

  context ".grade" do
    it "returns the grade that maps to the grade provided" do
      row = { "Grade" => "1" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.grade).to eq 1
    end
  end

  context ".gender" do
    context "when the gender is female" do
      it "returns the gender that maps to the gender provided" do
        row = { "Gender" => "1" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 1

        row = { "Gender" => "Female" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 1

        row = { "Gender" => "F" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 1
      end
    end

    context "when the gender is male" do
      it "returns the gender that maps to the gender provided" do
        row = { "Gender" => "2" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 2

        row = { "Gender" => "Male" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 2

        row = { "Gender" => "M" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 2
      end
    end

    context "when the gender is non-binary" do
      it "returns the gender that maps to the gender provided" do
        row = { "Gender" => "4" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 4

        row = { "Gender" => "N - Non-Binary" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 4

        row = { "Gender" => "N" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 4
      end
    end

    context "when the gender is not known" do
      it "returns the gender that maps to the gender provided" do
        row = { "Gender" => "N/A" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 99

        row = { "Gender" => "NA" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 99

        row = { "Gender" => "#N/A" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 99

        row = { "Gender" => "#NA" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 99

        row = { "Gender" => "Prefer not to disclose" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 99

        row = { "Gender" => "" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.gender).to eq 99
      end
    end
  end

  context ".races" do
    before do
      races
    end

    context "when the race is Native American" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "1" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1]

        row = { "Race" => "Native American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1]

        row = { "Race" => "American Indian or Alaskan Native" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1]
      end
    end

    context "when the race is Asian" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "2" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [2]

        row = { "Race" => "Asian" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [2]

        row = { "Race" => "Pacific Islander" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [2]

        row = { "Race" => "Pacific Island or Hawaiian Native" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [2]
      end
    end

    context "when the race is Black" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "3" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [3]

        row = { "Race" => "Black" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [3]

        row = { "Race" => "African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [3]
      end
    end

    context "when the race is Hispanic" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "4" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [4]

        row = { "Race" => "Hispanic" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [4]

        row = { "Race" => "Latinx" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [4]
      end
    end

    context "when the race is White" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "5" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [5]

        row = { "Race" => "White" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [5]

        row = { "Race" => "Caucasian" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [5]
      end
    end

    context "when the race is not disclosed" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "6" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "Prefer not to disclose" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]
      end
    end

    context "when the race is not disclosed" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "6" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "Prefer not to disclose" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]
      end
    end

    context "when the race is self described" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "7" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "Prefer to self-describe" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]
      end
    end

    context "when the race is Middle Eastern" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "8" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [8]

        row = { "Race" => "Middle Eastern" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [8]

        row = { "Race" => "North African" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [8]
      end
    end

    context "when the race is unknown" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "NA" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "#N/A" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "n/a" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "#na" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]

        row = { "Race" => "" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [99]
      end
    end

    context "when there are multiple races" do
      it "returns the gender that maps to the gender provided" do
        row = { "Race" => "1,2,3" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1, 2, 3, 100]

        row = { "Race" => "Alaskan Native, Pacific Islander, Black" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1, 2, 3, 100]

        row = { "Race" => "American Indian or Alaskan Native, Asian, African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1, 2, 3, 100]
        row = { "Race" => "n/a" }

        row = { "Race" => "American Indian or Alaskan Native, Asian and African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1, 2, 3, 100]

        row = { "Race" => "American Indian or Alaskan Native and Asian and African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1, 2, 3, 100]

        row = { "Race" => "American Indian or Alaskan Native and Asian, and African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [1, 2, 3, 100]

        row = { "Race" => "Asian, Caucasian and African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [2, 5, 3, 100]

        row = { "Race" => "Caucasian and Asian and African American" }
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [5, 2, 3, 100]

        row = { "Race- SIS" => "Caucasian and Asian and African American", "HispanicLatino" => "true" }
        headers.push("HispanicLatino")
        headers.push("Race- SIS")
        values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
        expect(values.races).to eq [5, 2, 3, 4, 100]
      end
    end
  end

  context ".respondent_type" do
    it "reads header to find the survey type" do
      headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
      values = SurveyItemValues.new(row: {}, headers:, survey_items:, schools:, academic_years:)
      expect(values.respondent_type).to eq :student

      headers = %w[t-sbel-q5 t-phys-q2]
      values = SurveyItemValues.new(row: {}, headers:, survey_items:, schools:, academic_years:)
      expect(values.respondent_type).to eq :teacher
    end
  end

  context ".survey_type" do
    context "when survey type is standard form" do
      it "returns the survey type" do
        headers = standard_survey_items
        values = SurveyItemValues.new(row: {}, headers:, survey_items:, schools:, academic_years:)
        expect(values.survey_type).to eq :standard
      end
    end
    context "when survey type is teacher form" do
      it "returns the survey type" do
        headers = teacher_survey_items
        values = SurveyItemValues.new(row: {}, headers:, survey_items:, schools:, academic_years:)
        expect(values.survey_type).to eq :teacher
      end
    end

    context "when survey type is short form" do
      it "returns the survey type" do
        headers = short_form_survey_items
        values = SurveyItemValues.new(row: {}, headers:, survey_items:, schools:, academic_years:)
        expect(values.survey_type).to eq :short_form
      end
    end

    context "when survey type is early education" do
      it "returns the survey type" do
        headers = early_education_survey_items
        values = SurveyItemValues.new(row: {}, headers:, survey_items:, schools:, academic_years:)
        expect(values.survey_type).to eq :early_education
      end
    end
  end

  context ".income" do
    before :each do
      attleboro
      ay_2022_23
    end

    it "translates Free Lunch to Economically Disadvantaged - Y" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "Free Lunch" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates Reduced Lunch to Economically Disadvantaged - Y" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "Reduced Lunch" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates LowIncome to Economically Disadvantaged - Y" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "LowIncome" }

      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates Not Eligible to Economically Disadvantaged - N" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "Not Eligible" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.income).to eq "Economically Disadvantaged - N"
    end

    it "translates ones to Economically Disadvantaged - Y" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "1" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates zeros to Economically Disadvantaged - N" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "0" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.income).to eq "Economically Disadvantaged - N"
    end

    it "translates blanks to Unknown" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.income).to eq "Unknown"
    end

    # NOTE: This will halt test runs too
    # it "halts execution if there is a value it cannot parse" do
    #   headers = ["LowIncome"]
    #   row = { "LowIncome" => "ArbitraryUnknownValue" }
    #   output = capture_stdout { SurveyItemValues.new(row:, headers:, survey_items:, schools:) }
    #   expect(output).to match "ArbitraryUnknownValue is not a known value. Halting execution"
    # end
  end

  context ".ell" do
    before :each do
      attleboro
      ay_2022_23
    end

    it 'translates "LEP Student 1st Year" or "LEP Student Not 1st Year" into ELL' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "LEP Student 1st Year" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "LEP Student Not 1st Year" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "LEP Student, Not 1st Year" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "EL student, not 1st year" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "EL student, 1st year" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "EL - Early Child. or PK" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"
    end

    it 'translates "Does not Apply" into "Not ELL"' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "Does not apply" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.ell).to eq "Not ELL"

      row = { "Raw ELL" => "Does Not APPLY" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.ell).to eq "Not ELL"
    end

    it 'tranlsates zeros into "Not ELL"' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "0" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "Not ELL"
    end

    it 'tranlsates NAs and blanks into "Not ELL"' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.ell).to eq "Not ELL"

      row = { "Raw ELL" => "NA" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "Not ELL"

      row = { "Raw ELL" => "#NA" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "Not ELL"

      row = { "Raw ELL" => "#N/A" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:)
      expect(values.ell).to eq "Not ELL"
    end

    # NOTE: This will halt test runs too
    # it "halts execution if there is a value it cannot parse" do
    #   headers = ["Raw ELL"]
    #   row = { "Raw ELL" => "ArbitraryUnknownValue" }

    #   output = capture_stdout { SurveyItemValues.new(row:, headers:, survey_items:, schools:) }
    #   expect(output).to match "ArbitraryUnknownValue is not a known value. Halting execution"
    # end
  end

  context ".sped" do
    before :each do
      attleboro
      ay_2022_23
    end

    it 'translates "active" into "Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "active" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Special Education"
    end

    it 'translates "A" into "Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "A" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Special Education"
    end

    it 'translates "I" into "Not Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "I" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Not Special Education"
    end

    it 'translates "exited" into "Not Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "exited" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Not Special Education"
    end

    it 'translates blanks into "Not Special Education' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Not Special Education"
    end

    it 'translates NA into "Not Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "NA" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Not Special Education"

      row = { "Raw SpEd" => "#NA" }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.sped).to eq "Not Special Education"
    end

    # NOTE: This will halt test runs too
    # it "halts execution if there is a value it cannot parse" do
    #   headers = ["Raw SpEd"]
    #   row = { "Raw SpEd" => "ArbitraryUnknownValue" }
    #   output = capture_stdout { SurveyItemValues.new(row:, headers:, survey_items:, schools:) }
    #   expect(output).to match "ArbitraryUnknownValue is not a known value. Halting execution"
    # end
  end

  context ".valid_duration" do
    context "when duration is valid" do
      it "returns true" do
        headers = standard_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "240", "Gender" => "Male" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq true

        headers = teacher_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "300" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq true

        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "100" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq true

        # When duration is blank or N/A or NA, we don't have enough information to kick out the row as invalid so we keep it in
        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq true

        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "N/A" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq true

        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "NA" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq true
      end
    end

    context "when duration is invalid" do
      it "returns false" do
        headers = standard_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "239" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq false

        headers = teacher_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "299" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq false
        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "99" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_duration?).to eq false
      end
    end
  end

  context ".progress" do
    it "returns the number of questions answered" do
      headers = standard_survey_items
      row = { "s-peff-q1" => 1, "s-peff-q2" => 1, "s-peff-q3" => 1, "s-peff-q4" => 1,
              "s-peff-q5" => 1, "s-peff-q6" => 1, "s-phys-q1" => 1, "s-phys-q2" => 1,
              "s-phys-q3" => 1, "s-phys-q4" => 1 }
      values = SurveyItemValues.new(row:, headers:, survey_items:, schools:, academic_years:)
      expect(values.progress).to eq 10
    end
  end

  context ".valid_progress" do
    context "when progress is valid" do
      it "when there are 17 or more standard survey items valid_progress returns true" do
        headers = standard_survey_items
        row = { "s-peff-q1" => 1, "s-peff-q2" => 1, "s-peff-q3" => 1, "s-peff-q4" => 1,
                "s-peff-q5" => 1, "s-peff-q6" => 1, "s-phys-q1" => 1, "s-phys-q2" => 1,
                "s-phys-q3" => 1, "s-phys-q4" => 1, "s-emsa-q1" => 1, "s-emsa-q2" => 1,
                "s-emsa-q3" => 1, "s-sbel-q1" => 1, "s-sbel-q2" => 1, "s-sbel-q3" => 1,
                "s-sbel-q4" => 1 }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 17
        expect(values.valid_progress?).to eq true
      end

      it "when there are 12 or more teacher survey items valid_progress returns true" do
        # When progress is blank or N/A or NA, we don't have enough information to kick out the row as invalid so we keep it in
        headers = teacher_survey_items

        row = {
          "t-pcom-q4" => 1, "t-pcom-q5" => 1, "t-inle-q1" => 1, "t-inle-q2" => 1,
          "t-coll-q3" => 1, "t-qupd-q1" => 1, "t-qupd-q2" => 1, "t-qupd-q3" => 1,
          "t-psup-q3" => 1, "t-psup-q4" => 1, "t-acch-q1" => 1, "t-acch-q2" => 1
        }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 12
        expect(values.valid_progress?).to eq true
      end

      it "when there are 5 or more short form survey items valid_progress returns true" do
        headers = short_form_survey_items
        row = { "s-peff-q1" => 1, "s-peff-q2" => 1, "s-peff-q3" => 1, "s-peff-q4" => 1,
                "s-sbel-q4" => 1 }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 5
        expect(values.valid_progress?).to eq true
      end

      it "when there are 5 or more early education survey items valid_progress returns true" do
        headers = early_education_survey_items
        row = { "s-peff-es1" => 1, "s-peff-es2" => 1, "s-peff-es3" => 1, "s-peff-es4" => 1,
                "s-peff-es5" => 1 }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 5
        expect(values.valid_progress?).to eq true
      end
    end

    context "when progress is invalid" do
      it "when there are fewer than 11 standard survey items valid_progress returns true" do
        headers = standard_survey_items
        row = { "s-peff-q1" => 1, "s-peff-q2" => 1, "s-peff-q3" => 1, "s-peff-q4" => 1,
                "s-peff-q5" => 1, "s-peff-q6" => 1, "s-phys-q1" => 1, "s-phys-q2" => 1,
                "s-emsa-q3" => 1, "s-sbel-q1" => 1 }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 10
        expect(values.valid_progress?).to eq false
      end

      it "when there are fewer than 12 teacher survey items valid_progress returns true" do
        # When progress is blank or N/A or NA, we don't have enough information to kick out the row as invalid so we keep it in
        headers = teacher_survey_items

        row = {
          "t-pcom-q4" => 1, "t-pcom-q5" => 1, "t-inle-q1" => 1, "t-inle-q2" => 1,
          "t-coll-q3" => 1, "t-qupd-q1" => 1, "t-qupd-q2" => 1, "t-qupd-q3" => 1,
          "t-psup-q3" => 1, "t-psup-q4" => 1, "t-acch-q1" => 1
        }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 11
        expect(values.valid_progress?).to eq false
      end

      it "when there are fewer than 5 short form survey items valid_progress returns true" do
        headers = short_form_survey_items
        row = { "s-peff-q1" => 1, "s-peff-q2" => 1, "s-peff-q3" => 1, "s-peff-q4" => 1 }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 4
        expect(values.valid_progress?).to eq false
      end

      it "when there are fewer than 5 early education survey items valid_progress returns true" do
        headers = early_education_survey_items
        row = { "s-peff-es1" => 1, "s-peff-es2" => 1, "s-peff-es3" => 1, "s-peff-es4" => 1 }
        values = SurveyItemValues.new(row:, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.progress).to eq 4
        expect(values.valid_progress?).to eq false
      end
    end
  end

  context ".valid_grade?" do
    context "when grade is valid" do
      before :each do
        attleboro
        attleboro_respondents
      end
      it "returns true for students" do
        headers = %w[s-sbel-q5 s-phys-q2 grade RecordedDate DeseID]
        values = SurveyItemValues.new(row: { "grade" => "9", "RecordedDate" => recorded_date, "DeseID" => "1234" }, headers:, survey_items:,
                                      schools:, academic_years:)

        expect(values.valid_grade?).to eq true
      end
      it "returns true for teachers" do
        headers = %w[t-sbel-q5 t-phys-q2 grade RecordedDate DeseID]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "DeseID" => "1234" }, headers:, survey_items:,
                                      schools:, academic_years:)
        expect(values.valid_grade?).to eq true
      end
    end

    context "when grade is invalid" do
      before :each do
        attleboro
        attleboro_respondents
      end
      it "returns false" do
        headers = %w[s-sbel-q5 s-phys-q2 grade RecordedDate DeseID]
        values = SurveyItemValues.new(row: { "grade" => "2", "RecordedDate" => recorded_date, "DeseID" => "1234" }, headers:, survey_items:,
                                      schools: School.by_dese_id)
        expect(values.valid_grade?).to eq false
      end
    end
  end

  context ".valid_sd?" do
    context "when the standard deviation is valid" do
      it "returns true for student questions" do
        headers = %w[s-sbel-q5 s-phys-q1 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "s-sbel-q5" => "1", "s-phys-q1" => "", "s-phys-q2" => "5" }, headers:, survey_items:,
                                      schools: School.by_dese_id)
        expect(values.valid_sd?).to eq true
      end
      it "returns true for teacher questions" do
        headers = %w[t-sbel-q5 t-phys-q2]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "t-sbel-q5" => "1", "t-phys-q2" => "5" }, headers:, survey_items:,
                                      schools: School.by_dese_id)
        expect(values.valid_sd?).to eq true
      end
    end

    context "when the standard deviation is invalid" do
      it "returns false for student questions" do
        headers = %w[s-sbel-q5 s-phys-q1 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "s-sbel-q5" => "1", "s-phys-q2" => "1" }, headers:, survey_items:,
                                      schools: School.by_dese_id)
        expect(values.valid_sd?).to eq false
      end
      it "returns false for teacher questions" do
        headers = %w[t-sbel-q5 t-phys-q1 t-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "t-sbel-q5" => "1", "t-phys-q2" => "1" }, headers:, survey_items:,
                                      schools: School.by_dese_id)
        expect(values.valid_sd?).to eq false
      end
    end
  end

  context ".academic_year" do
    before do
      create(:academic_year, range: "2020-21")
      create(:academic_year, range: "2021-22")
    end

    it "parses the date correctly when the date is in standard date format for google sheets: 'MM/DD/YYYY HH:MM:SS'" do
      recorded_date = "1/10/2022 14:21:45"
      values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "DeseID" => "1234" }, headers:, survey_items:,
                                    schools:, academic_years:)
      ay_21_22 = AcademicYear.find_by_range "2021-22"
      expect(values.academic_year).to eq ay_21_22
    end

    it "parses the date correctly when the date is in iso standard 8601 'YYYY-MM-DDTHH:MM:SS'" do
      recorded_date = "2022-1-10T14:21:45"
      values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "DeseID" => "1234" }, headers:, survey_items:,
                                    schools:, academic_years:)
      ay_21_22 = AcademicYear.find_by_range "2021-22"
      expect(values.academic_year).to eq ay_21_22
    end

    it "parses the date correctly when the date is in the format of: 'YYYY-MM-DD HH:MM:SS'" do
      recorded_date = "2022-01-10 14:21:45"
      values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "DeseID" => "1234" }, headers:, survey_items:,
                                    schools:, academic_years:)
      ay_21_22 = AcademicYear.find_by_range "2021-22"
      expect(values.academic_year).to eq ay_21_22
    end
  end
end
