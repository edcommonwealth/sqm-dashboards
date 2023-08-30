require "rails_helper"

describe StudentLoader do
  let(:path_to_student_responses) { Rails.root.join("spec", "fixtures", "test_2020-21_student_survey_responses.csv") }
  let(:american_indian) { create(:race, qualtrics_code: 1) }
  let(:asian)           { create(:race, qualtrics_code: 2) }
  let(:black)           { create(:race, qualtrics_code: 3) }
  let(:latinx)          { create(:race, qualtrics_code: 4) }
  let(:white)           { create(:race, qualtrics_code: 5) }
  let(:middle_eastern)  { create(:race, qualtrics_code: 8) }
  let(:unknown_race)    { create(:race, qualtrics_code: 99) }
  let(:multiracial)     { create(:race, qualtrics_code: 100) }
  let(:female)          { create(:gender, qualtrics_code: 1) }
  let(:male)            { create(:gender, qualtrics_code: 2) }
  let(:another_gender)  { create(:gender, qualtrics_code: 3) }
  let(:non_binary)      { create(:gender, qualtrics_code: 4) }
  let(:unknown_gender)  { create(:gender, qualtrics_code: 99) }

  before :each do
    american_indian
    asian
    black
    latinx
    white
    middle_eastern
    unknown_race
    multiracial
    female
    male
    another_gender
    non_binary
    unknown_gender
  end

  after :each do
    DatabaseCleaner.clean
  end
  xdescribe "#process_races" do
    context "as a standalone function" do
      it "race codes of 6 or 7 get classified as an unknown race" do
        codes = ["NA"]
        expect(StudentLoader.process_races(codes:)).to eq [unknown_race]
        codes = []
        expect(StudentLoader.process_races(codes:)).to eq [unknown_race]
        codes = [1]
        expect(StudentLoader.process_races(codes:)).to eq [american_indian]
        codes = [2]
        expect(StudentLoader.process_races(codes:)).to eq [asian]
        codes = [3]
        expect(StudentLoader.process_races(codes:)).to eq [black]
        codes = [4]
        expect(StudentLoader.process_races(codes:)).to eq [latinx]
        codes = [5]
        expect(StudentLoader.process_races(codes:)).to eq [white]
        codes = [8]
        expect(StudentLoader.process_races(codes:)).to eq [middle_eastern]
        codes = [6]
        expect(StudentLoader.process_races(codes:)).to eq [unknown_race]
        codes = [7]
        expect(StudentLoader.process_races(codes:)).to eq [unknown_race]
        codes = [6, 7]
        expect(StudentLoader.process_races(codes:)).to eq [unknown_race]
        codes = [1, 6, 7]
        expect(StudentLoader.process_races(codes:)).to eq [american_indian]
        codes = [1, 6, 7, 2]
        expect(StudentLoader.process_races(codes:)).to eq [american_indian, asian, multiracial]
        codes = [3, 6, 7, 6, 6, 7, 7, 6, 2]
        expect(StudentLoader.process_races(codes:)).to eq [black, asian, multiracial]
        codes = [8, 2]
        expect(StudentLoader.process_races(codes:)).to eq [middle_eastern, asian, multiracial]
      end
    end
  end

  xdescribe "#add_multiracial_designation" do
    it "adds the multiracial race code to the list of races" do
      races = [unknown_race]
      expect(StudentLoader.add_multiracial_designation(races:)).to eq [unknown_race]
      races = [american_indian, asian]
      expect(StudentLoader.add_multiracial_designation(races:)).to eq [american_indian, asian, multiracial]
      races = [white]
      expect(StudentLoader.add_multiracial_designation(races:)).to eq [white]
    end
  end

  # This fails in CI because github does not know what the key derivation salt is.
  # I'm not sure how to securely set the key derivation salt as an environment variable in CI
  describe "self.load_data" do
    context "load student data for all schools" do
      before :each do
        SurveyResponsesDataLoader.new.load_data filepath: path_to_student_responses
        StudentLoader.load_data filepath: path_to_student_responses
      end

      it "ensures student responses load correctly" do
        assigns_student_to_the_survey_item_responses
        assigns_races_to_students
        is_idempotent_for_students
      end
    end

    # TODO: get this test to run correctly.  Since we are no longer seeding, we need to define schools, and districts; some Lowell, some not
    xcontext "When using the rule to skip non Lowell schools" do
      before :each do
        SurveyResponsesDataLoader.new.load_data filepath: path_to_student_responses
        StudentLoader.load_data filepath: path_to_student_responses, rules: [Rule::SkipNonLowellSchools]
      end

      it "only loads student data for lowell" do
        expect(Student.find_by_response_id("student_survey_response_1")).to eq nil
        expect(Student.find_by_response_id("student_survey_response_3").races).to eq [unknown_race]
        expect(Student.find_by_response_id("student_survey_response_4").races).to eq [unknown_race]
        expect(Student.find_by_response_id("student_survey_response_5").races).to eq [american_indian, asian, black, latinx, white,
                                                                                      middle_eastern, multiracial]
        expect(Student.find_by_response_id("student_survey_response_6").races).to eq [american_indian, asian, black, latinx, white,
                                                                                      middle_eastern, multiracial]
        expect(Student.find_by_response_id("student_survey_response_7").races).to eq [unknown_race]
      end
    end
  end
end

def assigns_student_to_the_survey_item_responses
  # The csv file has no responses for `student_survey_response_2` so we can't assign a student to nil responses
  expect(SurveyItemResponse.find_by_response_id("student_survey_response_2")).to eq nil

  response_ids = %w[student_survey_response_1 student_survey_response_3
                    student_survey_response_4
                    student_survey_response_5
                    student_survey_response_6
                    student_survey_response_7]

  response_ids.each do |response_id|
    responses = SurveyItemResponse.where(response_id:)
    responses.each do |response|
      expect(response.student).not_to eq nil
      expect(response.student).to eq Student.find_by_response_id(response_id)
    end
  end
end

def assigns_races_to_students
  expect(Student.find_by_response_id("student_survey_response_1").races).to eq [american_indian]
  expect(Student.find_by_response_id("student_survey_response_2").races).to eq [asian, black, latinx, multiracial]
  expect(Student.find_by_response_id("student_survey_response_3").races).to eq [unknown_race]
  expect(Student.find_by_response_id("student_survey_response_4").races).to eq [unknown_race]
  expect(Student.find_by_response_id("student_survey_response_5").races).to eq [american_indian, asian, black, latinx, white,
                                                                                middle_eastern, multiracial]
  expect(Student.find_by_response_id("student_survey_response_6").races).to eq [american_indian, asian, black, latinx, white,
                                                                                middle_eastern, multiracial]
  expect(Student.find_by_response_id("student_survey_response_7").races).to eq [unknown_race]
end

def is_idempotent_for_students
  number_of_students = Student.count
  number_of_responses = SurveyItemResponse.count
  StudentLoader.load_data filepath: path_to_student_responses
  expect(Student.count).to eq number_of_students
  expect(SurveyItemResponse.count).to eq number_of_responses
end
