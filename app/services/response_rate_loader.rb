# frozen_string_literal: true

class ResponseRateLoader
  def self.reset(schools: School.all, academic_years: AcademicYear.all, subcategories: Subcategory.all)
    subcategories.each do |subcategory|
      schools.each do |school|
        next if rails_env == 'test' && (school != milford)

        academic_years.each do |academic_year|
          next if rails_env == 'test' && (academic_year != test_year)

          process_response_rate(subcategory:, school:, academic_year:)
        end
      end
    end
  end

  private

  def self.milford
    School.find_by_slug 'milford-high-school'
  end

  def self.test_year
    AcademicYear.find_by_range '2020-21'
  end

  def self.rails_env
    @rails_env ||= ENV['RAILS_ENV']
  end

  def self.process_response_rate(subcategory:, school:, academic_year:)
    student = StudentResponseRateCalculator.new(subcategory:, school:, academic_year:)
    teacher = TeacherResponseRateCalculator.new(subcategory:, school:, academic_year:)

    response_rate = ResponseRate.find_or_create_by!(subcategory:, school:, academic_year:)

    response_rate.update!(student_response_rate: student.rate, teacher_response_rate: teacher.rate,
                          meets_student_threshold: student.meets_student_threshold?,
                          meets_teacher_threshold: teacher.meets_teacher_threshold?)
  end

  private_class_method :milford
  private_class_method :test_year
  private_class_method :rails_env
  private_class_method :process_response_rate
end
