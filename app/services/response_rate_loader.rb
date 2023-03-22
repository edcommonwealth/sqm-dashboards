# frozen_string_literal: true

class ResponseRateLoader
  def self.reset(schools: School.all, academic_years: AcademicYear.all, subcategories: Subcategory.all)
    subcategories.each do |subcategory|
      schools.each do |school|
        academic_years.each do |academic_year|
          process_response_rate(subcategory:, school:, academic_year:)
        end
      end
    end
  end

  private

  def self.process_response_rate(subcategory:, school:, academic_year:)
    student = StudentResponseRateCalculator.new(subcategory:, school:, academic_year:)
    teacher = TeacherResponseRateCalculator.new(subcategory:, school:, academic_year:)

    response_rate = ResponseRate.find_or_create_by!(subcategory:, school:, academic_year:)

    response_rate.update!(student_response_rate: student.rate,
                          teacher_response_rate: teacher.rate,
                          meets_student_threshold: student.meets_student_threshold?,
                          meets_teacher_threshold: teacher.meets_teacher_threshold?)
  end

  private_class_method :process_response_rate
end
