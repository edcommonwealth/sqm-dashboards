class ResponseRateLoader
  def self.refresh
    schools = School.all
    academic_years = AcademicYear.all
    subcategories = Subcategory.all

    milford = School.find_by_slug 'milford-high-school'

    # ResponseRate.new(school:, academic_year:, subcategory:, student_response_rate: 50, teacher_response_rate: 50,
    #                  meets_student_threshold: true, meets_teacher_threshold: true).save

    test_year = AcademicYear.find_by_range '2020-21'
    subcategories.each do |subcategory|
      schools.each do |school|
        next if ENV['RAILS_ENV'] == 'test' && !(school == milford)

        academic_years.each do |academic_year|
          next if ENV['RAILS_ENV'] == 'test' && !(academic_year == test_year)

          student = StudentResponseRateCalculator.new(subcategory:, school:, academic_year:)
          teacher = TeacherResponseRateCalculator.new(subcategory:, school:, academic_year:)

          response_rate = ResponseRate.find_or_create_by!(subcategory:, school:, academic_year:)

          response_rate.student_response_rate = student.rate
          response_rate.teacher_response_rate = teacher.rate
          response_rate.meets_student_threshold = student.meets_student_threshold?
          response_rate.meets_teacher_threshold = teacher.meets_teacher_threshold?
          response_rate.save
        end
      end
    end
  end
end
