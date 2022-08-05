require 'rails_helper'

describe StudentLoader do
  let(:path_to_student_responses) { Rails.root.join('spec', 'fixtures', 'test_2020-21_student_survey_responses.csv') }
  let(:american_indian) { Race.find_by_qualtrics_code(1) }
  let(:asian) { Race.find_by_qualtrics_code(2) }
  let(:black) { Race.find_by_qualtrics_code(3) }
  let(:latinx) { Race.find_by_qualtrics_code(4) }
  let(:white) { Race.find_by_qualtrics_code(5) }
  let(:middle_eastern) { Race.find_by_qualtrics_code(8) }
  let(:unknown) { Race.find_by_qualtrics_code(99) }
  let(:multiracial) { Race.find_by_qualtrics_code(100) }

  before :each do
    Rails.application.load_seed
  end

  after :each do
    DatabaseCleaner.clean
  end
  describe '#process_races' do
    context 'as a standalone function' do
      it 'race codes of 6 or 7 get classified as an unknown race' do
        codes = [6]
        expect(StudentLoader.process_races(codes:)).to eq [unknown]
        codes = [7]
        expect(StudentLoader.process_races(codes:)).to eq [unknown]
        codes = [6, 7]
        expect(StudentLoader.process_races(codes:)).to eq [unknown]
        codes = [1, 6, 7]
        expect(StudentLoader.process_races(codes:)).to eq [american_indian]
      end
    end
  end

  describe '#add_multiracial_designation' do
      it 'adds the multiracial race code to the list of races' do
        races = [unknown]
        expect(StudentLoader.add_multiracial_designation(races:)).to eq [unknown]
        races = [american_indian, asian]
        expect(StudentLoader.add_multiracial_designation(races:)).to eq [american_indian, asian, multiracial]
        races = [white]
        expect(StudentLoader.add_multiracial_designation(races:)).to eq [white]
      end
  end


  # This fails in CI because github does not know what the key derivation salt is.
  # I'm not sure how to securely set the key derivation salt as an environment variable in CI
  xdescribe 'self.load_data' do
    context 'load student data' do
      before :each do
        SurveyResponsesDataLoader.load_data filepath: path_to_student_responses
        StudentLoader.load_data filepath: path_to_student_responses
      end

      it 'ensures student responses load correctly' do
        assigns_student_to_the_survey_item_responses
        assigns_races_to_students
        is_idempotent_for_students
      end
    end
  end
end

def assigns_student_to_the_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id('student_survey_response_1').student).not_to eq nil
  expect(SurveyItemResponse.find_by_response_id('student_survey_response_1').student).to eq Student.find_by_lasid('123456')
  expect(SurveyItemResponse.find_by_response_id('student_survey_response_6').student).not_to eq nil
  expect(SurveyItemResponse.find_by_response_id('student_survey_response_6').student).to eq Student.find_by_response_id('student_survey_response_6')
end

def assigns_races_to_students
  expect(Student.find_by_response_id('student_survey_response_1').races).to eq [american_indian]
  expect(Student.find_by_response_id('student_survey_response_2').races).to eq [asian, black, latinx, multiracial]
  expect(Student.find_by_response_id('student_survey_response_3').races).to eq [unknown]
  expect(Student.find_by_response_id('student_survey_response_4').races).to eq [unknown]
  expect(Student.find_by_response_id('student_survey_response_5').races).to eq [american_indian, asian, black, latinx, white,
                                                                                middle_eastern, multiracial]
  expect(Student.find_by_response_id('student_survey_response_6').races).to eq [american_indian, asian, black, latinx, white,
                                                                                middle_eastern, multiracial]
  expect(Student.find_by_response_id('student_survey_response_7').races).to eq [unknown]
end

def is_idempotent_for_students
  number_of_students = Student.count
  StudentLoader.load_data filepath: path_to_student_responses
  expect(Student.count).to eq number_of_students
end
