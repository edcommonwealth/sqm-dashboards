require 'rails_helper'

describe EnrollmentLoader do
  let(:path_to_admin_data) { Rails.root.join('spec', 'fixtures', 'sample_enrollment_data.csv') }
  let(:ay_2022_23) { AcademicYear.find_by_range '2022-23' }
  let(:attleboro) { School.find_by_dese_id 160_505 }
  let(:winchester) { School.find_by_dese_id 3_440_505 }
  let(:beachmont) { School.find_by_dese_id 2_480_013 }

  before :each do
    Rails.application.load_seed
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe 'self.load_data' do
    before :each do
      EnrollmentLoader.load_data filepath: path_to_admin_data
    end
    it 'loads the correct enrollment numbers' do
      respondents = Respondent.where(school: attleboro, academic_year: ay_2022_23)
      academic_year = ay_2022_23
      expect(Respondent.find_by(school: attleboro, academic_year:).nine).to eq 506

      expect(Respondent.find_by(school: beachmont, academic_year:).pk).to eq 34
      expect(Respondent.find_by(school: beachmont, academic_year:).k).to eq 64
      expect(Respondent.find_by(school: beachmont, academic_year:).one).to eq 58

      expect(Respondent.find_by(school: winchester, academic_year:).nine).to eq 361
      expect(Respondent.find_by(school: winchester, academic_year:).ten).to eq 331
      expect(Respondent.find_by(school: winchester, academic_year:).eleven).to eq 339
      expect(Respondent.find_by(school: winchester, academic_year:).twelve).to eq 352
    end
  end

  # describe 'output to console' do
  #   it 'outputs a messsage saying a value has been rejected' do
  #     output = capture_stdout { EnrollmentLoader.load_data filepath: path_to_admin_data }.gsub("\n", '')
  #     expect(output).to eq 'Invalid score: 0.0        for school: Attleboro High School        admin data item a-reso-i1 Invalid score: 100.0        for school: Winchester High School        admin data item a-sust-i3 '
  #   end
  # end
end

# def capture_stdout
#   original_stdout = $stdout
#   $stdout = fake = StringIO.new
#   begin
#     yield
#   ensure
#     $stdout = original_stdout
#   end
#   fake.string
# end
