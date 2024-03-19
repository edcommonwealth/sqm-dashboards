module Report
  class BeyondLearningLoss
    def self.create_report(schools: School.all.includes(:district), academic_years: AcademicYear.all, scales: ::Scale.all, filename: "bll_report.csv")
      data = []
      mutex = Thread::Mutex.new
      data << ["District", "School", "School Code", "Academic Year", "Recorded Date Range", "Grades", "Measure", "Scale",
               "All Score (Average)"]
      pool_size = 2
      jobs = Queue.new
      schools.each { |school| jobs << school }

      workers = pool_size.times.map do
        Thread.new do
          while school = jobs.pop(true)
            academic_years.each do |academic_year|
              scales.each do |scale|
                respondents = Respondent.by_school_and_year(school:, academic_year:)
                next if respondents.nil?

                response_rate = scale.measure.subcategory.response_rate(school:, academic_year:)
                next unless response_rate.meets_student_threshold? || response_rate.meets_teacher_threshold?

                score = scale.score(school:, academic_year:)

                begin_date = SurveyItemResponse.where(school:,
                                                      academic_year:).where.not(recorded_date: nil).order(:recorded_date).first&.recorded_date&.to_date
                end_date = SurveyItemResponse.where(school:,
                                                    academic_year:).where.not(recorded_date: nil).order(:recorded_date).last&.recorded_date&.to_date
                date_range = "#{begin_date} - #{end_date}"

                row = [response_rate, scale, school, academic_year]

                all_grades = respondents.enrollment_by_grade.keys
                grades = "#{all_grades.first}-#{all_grades.last}"
                mutex.synchronize do
                  data << [school.district.name,
                           school.name,
                           school.dese_id,
                           academic_year.range,
                           date_range,
                           grades,
                           scale.measure.measure_id,
                           scale.scale_id,
                           score]
                end
              end
            end
          end
        rescue ThreadError
        end
      end

      workers.each(&:join)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.write_csv(data:, filepath:)
      csv = CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
      File.write(filepath, csv)
    end
  end
end
