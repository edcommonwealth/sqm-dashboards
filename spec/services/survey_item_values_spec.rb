require "rails_helper"

RSpec.describe SurveyItemValues, type: :model do
  let(:headers) do
    ["StartDate", "EndDate", "Status", "IPAddress", "Progress", "Duration (in seconds)", "Finished", "RecordedDate",
     "ResponseId", "RecipientLastName", "RecipientFirstName", "RecipientEmail", "ExternalReference", "LocationLatitude", "LocationLongitude", "DistributionChannel", "UserLanguage", "District", "School- Lee", "School- Maynard", "LASID", "Grade", "s-emsa-q1", "s-emsa-q2", "s-emsa-q3", "s-tint-q1", "s-tint-q2", "s-tint-q3", "s-tint-q4", "s-tint-q5", "s-acpr-q1", "s-acpr-q2", "s-acpr-q3", "s-acpr-q4", "s-cure-q1", "s-cure-q2", "s-cure-q3", "s-cure-q4", "s-sten-q1", "s-sten-q2", "s-sten-q3", "s-sper-q1", "s-sper-q2", "s-sper-q3", "s-sper-q4", "s-civp-q1", "s-civp-q2", "s-civp-q3", "s-civp-q4", "s-grmi-q1", "s-grmi-q2", "s-grmi-q3", "s-grmi-q4", "s-appa-q1", "s-appa-q2", "s-appa-q3", "s-peff-q1", "s-peff-q2", "s-peff-q3", "s-peff-q4", "s-peff-q5", "s-peff-q6", "s-sbel-q1", "s-sbel-q2", "s-sbel-q3", "s-sbel-q4", "s-sbel-q5", "s-phys-q1", "s-phys-q2", "s-phys-q3", "s-phys-q4", "s-vale-q1", "s-vale-q2", "s-vale-q3", "s-vale-q4", "s-acst-q1", "s-acst-q2", "s-acst-q3", "s-sust-q1", "s-sust-q2", "s-grit-q1", "s-grit-q2", "s-grit-q3", "s-grit-q4", "s-expa-q1", "s-poaf-q1", "s-poaf-q2", "s-poaf-q3", "s-poaf-q4", "s-tint-q1-1", "s-tint-q2-1", "s-tint-q3-1", "s-tint-q4-1", "s-tint-q5-1", "s-acpr-q1-1", "s-acpr-q2-1", "s-acpr-q3-1", "s-acpr-q4-1", "s-peff-q1-1", "s-peff-q2-1", "s-peff-q3-1", "s-peff-q4-1", "s-peff-q5-1", "s-peff-q6-1", "Gender", "Race"]
  end
  let(:genders) do
    create(:gender, qualtrics_code: 1)
    Gender.by_qualtrics_code
  end
  let(:survey_items) { [] }
  let(:district) { create(:district, name: "Attleboro") }
  let(:attleboro) do
    create(:school, name: "Attleboro", dese_id: 1234, district:)
  end
  let(:attleboro_respondents) do
    create(:respondent, school: attleboro, academic_year: ay_2022_23, nine: 40, ten: 40, eleven: 40, twelve: 40)
  end
  let(:schools) { School.school_hash }
  let(:recorded_date) { "2023-04-01" }
  let(:ay_2022_23) do
    create(:academic_year, range: "2022-23")
  end

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
    survey_item_ids = [create(:survey_item, survey_item_id: "s-phys-q1", on_short_form: true),
                       create(:survey_item, survey_item_id: "s-phys-q2", on_short_form: true),
                       create(:survey_item, survey_item_id: "s-phys-q3",
                                            on_short_form: true)].map(&:survey_item_id)
    survey_item_ids.map do |survey_item_id|
      create(:survey_item, survey_item_id:)
    end
    (survey_item_ids << common_headers).flatten
  end

  let(:early_education_survey_items) do
    survey_item_ids = [create(:survey_item, survey_item_id: "s-emsa-es1"),
                       create(:survey_item, survey_item_id: "s-emsa-es2"),
                       create(:survey_item, survey_item_id: "s-emsa-es3")].map(&:survey_item_id)
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
      row = { "RecordedDate" => "2017-01-01" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.recorded_date).to eq Date.parse("2017-01-01")

      headers = ["Recorded Date"]
      row = { "Recorded Date" => "2017-01-02" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.recorded_date).to eq Date.parse("2017-01-02")
    end
  end

  context ".school" do
    it "returns the school that maps to the dese id provided" do
      attleboro
      headers = ["Dese ID"]
      row = { "Dese ID" => "1234" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.school).to eq attleboro

      row = { "DeseID" => "1234" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.school).to eq attleboro
    end
  end

  context ".grade" do
    it "returns the grade that maps to the grade provided" do
      row = { "Grade" => "1" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.grade).to eq 1
    end
  end
  context ".gender" do
    it "returns the grade that maps to the grade provided" do
      row = { "Gender" => "1" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.gender.qualtrics_code).to eq 1
    end
  end

  context ".respondent_type" do
    it "reads header to find the survey type" do
      headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
      values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
      expect(values.respondent_type).to eq :student

      headers = %w[t-sbel-q5 t-phys-q2]
      values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
      expect(values.respondent_type).to eq :teacher
    end
  end

  context ".survey_type" do
    context "when survey type is standard form" do
      it "returns the survey type" do
        headers = standard_survey_items
        values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
        expect(values.survey_type).to eq :standard
      end
    end
    context "when survey type is teacher form" do
      it "returns the survey type" do
        headers = teacher_survey_items
        values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
        expect(values.survey_type).to eq :teacher
      end
    end

    context "when survey type is short form" do
      it "returns the survey type" do
        headers = short_form_survey_items
        values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
        expect(values.survey_type).to eq :short_form
      end
    end

    context "when survey type is early education" do
      it "returns the survey type" do
        headers = early_education_survey_items
        values = SurveyItemValues.new(row: {}, headers:, genders:, survey_items:, schools:)
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
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates Reduced Lunch to Economically Disadvantaged - Y" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "Reduced Lunch" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates LowIncome to Economically Disadvantaged - Y" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "LowIncome" }

      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.income).to eq "Economically Disadvantaged - Y"
    end

    it "translates Not Eligible to Economically Disadvantaged - N" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "Not Eligible" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.income).to eq "Economically Disadvantaged - N"
    end

    it "translates blanks to Unknown" do
      headers = ["LowIncome"]
      row = { "LowIncome" => "" }

      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.income).to eq "Unknown"
    end
  end

  context ".ell" do
    before :each do
      attleboro
      ay_2022_23
    end

    it 'translates "LEP Student 1st Year" or "LEP Student Not 1st Year" into ELL' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "LEP Student 1st Year" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "LEP Student Not 1st Year" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"

      row = { "Raw ELL" => "LEP Student Not 1st Year" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "ELL"
    end

    it 'translates "Does not Apply" into "Not ELL"' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "Does not apply" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "Not ELL"

      row = { "Raw ELL" => "Does Not APPLY" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "Not ELL"
    end

    it 'tranlsates blanks into "Unknown"' do
      headers = ["Raw ELL"]
      row = { "Raw ELL" => "" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "Unknown"

      row = { "Raw ELL" => "Anything else" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.ell).to eq "Unknown"
    end
  end

  context ".sped" do
    before :each do
      attleboro
      ay_2022_23
    end

    it 'translates "active" into "Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "active" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.sped).to eq "Special Education"
    end

    it 'translates "exited" into "Not Special Education"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "exited" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.sped).to eq "Not Special Education"
    end
    it 'translates blanks into "Not Special Education' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.sped).to eq "Not Special Education"
    end

    it 'tranlsates NA into "Unknown"' do
      headers = ["Raw SpEd"]
      row = { "Raw SpEd" => "NA" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.sped).to eq "Unknown"

      row = { "Raw SpEd" => "#NA" }
      values = SurveyItemValues.new(row:, headers:, genders:, survey_items:, schools:)
      expect(values.sped).to eq "Unknown"
    end
  end

  context ".valid_duration" do
    context "when duration is valid" do
      it "returns true" do
        headers = standard_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "240", "Gender" => "Male" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true

        headers = teacher_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "300" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true

        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "100" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true

        # When duration is blank or N/A or NA, we don't have enough information to kick out the row as invalid so we keep it in
        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true

        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "N/A" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true

        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "NA" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq true
      end
    end

    context "when duration is invalid" do
      it "returns false" do
        headers = standard_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "239" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq false

        headers = teacher_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "299" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq false
        headers = short_form_survey_items
        values = SurveyItemValues.new(row: { "Duration (in seconds)" => "99" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_duration?).to eq false
      end
    end
  end

  context ".valid_progress" do
    context "when progress is valid" do
      it "returns true" do
        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "Progress" => "25" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_progress?).to eq true

        # When progress is blank or N/A or NA, we don't have enough information to kick out the row as invalid so we keep it in
        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "Progress" => "" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_progress?).to eq true

        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "Progress" => "N/A" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_progress?).to eq true

        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "Progress" => "NA" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_progress?).to eq true
      end
    end

    context "when progress is invalid" do
      it "returns false" do
        headers = %w[s-sbel-q5 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "Progress" => "24" }, headers:, genders:, survey_items:,
                                      schools:)
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
        headers = %w[s-sbel-q5 s-phys-q2 grade RecordedDate]
        values = SurveyItemValues.new(row: { "grade" => "9", "RecordedDate" => recorded_date, "Dese ID" => "1234" }, headers:, genders:, survey_items:,
                                      schools:)

        expect(values.valid_grade?).to eq true
      end
      it "returns true for teachers" do
        headers = %w[t-sbel-q5 t-phys-q2 grade RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234" }, headers:, genders:, survey_items:,
                                      schools:)
        expect(values.valid_grade?).to eq true
      end
    end

    context "when grade is invalid" do
      before :each do
        attleboro
        attleboro_respondents
      end
      it "returns false" do
        headers = %w[s-sbel-q5 s-phys-q2 grade RecordedDate]
        values = SurveyItemValues.new(row: { "grade" => "2", "RecordedDate" => recorded_date, "Dese ID" => "1234" }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_grade?).to eq false
      end
    end
  end

  context ".valid_sd?" do
    context "when the standard deviation is valid" do
      it "returns true for student questions" do
        headers = %w[s-sbel-q5 s-phys-q1 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "s-sbel-q5" => "1", "s-phys-q1" => "", "s-phys-q2" => "5" }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq true
      end
      it "returns true for teacher questions" do
        headers = %w[t-sbel-q5 t-phys-q2]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "t-sbel-q5" => "1", "t-phys-q2" => "5" }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq true
      end
    end

    context "when the standard deviation is invalid" do
      it "returns false for student questions" do
        headers = %w[s-sbel-q5 s-phys-q1 s-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "s-sbel-q5" => "1", "s-phys-q2" => "1" }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq false
      end
      it "returns false for teacher questions" do
        headers = %w[t-sbel-q5 t-phys-q1 t-phys-q2 RecordedDate]
        values = SurveyItemValues.new(row: { "RecordedDate" => recorded_date, "Dese ID" => "1234", "t-sbel-q5" => "1", "t-phys-q2" => "1" }, headers:, genders:, survey_items:,
                                      schools: School.school_hash)
        expect(values.valid_sd?).to eq false
      end
    end
  end
end
