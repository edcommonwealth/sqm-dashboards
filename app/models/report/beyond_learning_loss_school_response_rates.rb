module Report
  class BeyondLearningLossSchoolResponseRates
    def self.create_report(schools: School.all.includes(:district), academic_years: AcademicYear.all, filename: "bll_response_rate_report.csv")
      data = to_csv(schools:, academic_years:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.to_csv(schools:, academic_years:)
      data = []
      mutex = Thread::Mutex.new
      headers = ["District", "School", "School Code", "Academic Year", "Recorded Date Range", "Grades"]
      (0..12).each do |grade|
        headers << "Number of responses for grade #{grade}"
        headers << "Number of questions given to grade #{grade}"
        headers << "Average number of responses per question for grade #{grade}"
        headers << "Number of students in grade #{grade}"
        headers << "Response rate for grade #{grade} (Rate per grade for all questions regardless of subcategory)"
        headers << "Response rate for grade #{grade} (Rate per grade grouped by subcategory, then averaged)"
        headers << "Number of students that participated in the survey.  (grade #{grade})"
        headers << "Participation rate for grade #{grade} (Percentage of students who participated in survey)"
      end

      subcategories_with_student_survey_items =
        ::Subcategory.select do |subcategory|
          subcategory.student_survey_items.count.positive?
        end
      student_survey_items = ::SurveyItem.student_survey_items
      early_education_survey_items = ::SurveyItem.early_education_survey_items

      data << headers
      pool_size = 2
      jobs = Queue.new
      schools.each { |school| jobs << school }

      workers = pool_size.times.map do
        Thread.new do
          while school = jobs.pop(true)
            academic_years.each do |academic_year|
              respondents = Respondent.by_school_and_year(school:, academic_year:)
              next if respondents.nil?

              begin_date = ::SurveyItemResponse.where(school:,
                                                      academic_year:).where.not(recorded_date: nil).order(:recorded_date).first&.recorded_date&.to_date
              end_date = ::SurveyItemResponse.where(school:,
                                                    academic_year:).where.not(recorded_date: nil).order(:recorded_date).last&.recorded_date&.to_date
              date_range = "#{begin_date} - #{end_date}"

              all_grades = respondents.enrollment_by_grade.keys
              grades = "#{all_grades.first}-#{all_grades.last}"

              mutex.synchronize do
                data_row = [school.district.name,
                            school.name,
                            school.dese_id,
                            academic_year.range,
                            date_range,
                            grades]

                (0..12).each do |grade|
                  response_rate_for_grade =
                    subcategories_with_student_survey_items.map do |subcategory|
                      calc = ::StudentResponseRateCalculator.new(subcategory:, school:,
                                                                 academic_year:)
                      calc.rates_by_grade[grade]
                    end.remove_blanks.average

                  # response_rate_for_grade = response_rate_for_grade.remove_blanks.average
                  response_rate_for_grade = "" if response_rate_for_grade.nan?

                  respondent_count = respondents.for_grade(grade).to_f

                  threshold = 10
                  quarter_of_grade = if respondent_count.nil?
                                       10
                                     else
                                       respondent_count / 4.0
                                     end
                  threshold = threshold > quarter_of_grade ? quarter_of_grade : threshold

                  survey_items_with_sufficient_responses = ::SurveyItem.where(id: ::SurveyItem.joins("inner join survey_item_responses on survey_item_responses.survey_item_id = survey_items.id")
                                                  .student_survey_items
                                                  .where("survey_item_responses.school": school,
                                                         "survey_item_responses.academic_year": academic_year,
                                                         "survey_item_responses.survey_item_id": student_survey_items,
                                                         "survey_item_responses.grade": grade)
                                                  .group("survey_items.id")
                                                  .having("count(*) >= #{threshold}")
                                                  .count.keys)

                  student_responses = ::SurveyItemResponse.where(school:, academic_year:,
                                                                 survey_item: survey_items_with_sufficient_responses, grade:)
                  survey_item_count = student_responses.pluck(:survey_item_id).uniq.count.to_f
                  average_number_of_responses_per_question = if survey_item_count.positive?
                                                               student_responses.count.to_f / survey_item_count
                                                             else
                                                               0
                                                             end

                  simple_response_rate_calculation = if respondent_count.nil?
                                                       0.to_f
                                                     else
                                                       average_number_of_responses_per_question.to_f / respondent_count * 100

                                                     end
                  simple_response_rate_calculation = "" if simple_response_rate_calculation.nan?

                  non_early_ed_items = student_survey_items - early_education_survey_items
                  non_early_ed_count = ::SurveyItemResponse.where(school:, academic_year:,
                                                                  survey_item: non_early_ed_items, grade:).select(:response_id).distinct.count || 0

                  early_ed_items = early_education_survey_items
                  early_ed_count = ::SurveyItemResponse.where(school:, academic_year:,
                                                              survey_item: early_ed_items, grade:)
                                                       .group(:survey_item)
                                                       .select(:response_id)
                                                       .distinct
                                                       .count
                                                       .values.max || 0

                  participation_count = non_early_ed_count + early_ed_count
                  participation_count = 0 if participation_count < threshold
                  participation_rate = participation_count / respondent_count * 100
                  participation_rate = 0 if participation_rate.nil? || participation_rate.nan? || participation_rate < 5

                  data_row << student_responses.count
                  data_row << survey_item_count
                  data_row << average_number_of_responses_per_question
                  data_row << respondent_count
                  data_row << simple_response_rate_calculation
                  data_row << response_rate_for_grade
                  data_row << participation_count
                  data_row << participation_rate
                end
                data << data_row
              end
            end
          end
        rescue ThreadError
        end
      end

      workers.each(&:join)
      CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
    end

    def self.write_csv(data:, filepath:)
      File.write(filepath, data)
    end
  end
end
