module Report
  class Measure
    def self.create_report(schools: School.all.includes(:district), academic_years: AcademicYear.all, measures: ::Measure.all, filename: "measure_report.csv")
      data = to_csv(schools, academic_years:, measures:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.to_csv(schools:, academic_years:, measures:)
      data = []
      mutex = Thread::Mutex.new
      data << ["Measure Name", "Measure ID", "District", "School", "School Code", "Academic Year", "Recorded Date Range", "Grades", "Student Score", "Student Zone", "Teacher Score",
               "Teacher Zone", "Admin Score", "Admin Zone", "All Score (Average)", "All Score Zone"]
      pool_size = 2
      jobs = Queue.new
      schools.each { |school| jobs << school }

      workers = pool_size.times.map do
        Thread.new do
          while school = jobs.pop(true)
            academic_years.each do |academic_year|
              measures.each do |measure|
                respondents = Respondent.by_school_and_year(school:, academic_year:)
                next if respondents.nil?

                response_rate = measure.subcategory.response_rate(school:, academic_year:)
                next unless response_rate.meets_student_threshold? || response_rate.meets_teacher_threshold?

                score = measure.score(school:, academic_year:)
                zone = measure.zone(school:, academic_year:).type.to_s.capitalize

                begin_date = ::SurveyItemResponse.where(school:,
                                                        academic_year:).where.not(recorded_date: nil).order(:recorded_date).first&.recorded_date&.to_date
                end_date = ::SurveyItemResponse.where(school:,
                                                      academic_year:).where.not(recorded_date: nil).order(:recorded_date).last&.recorded_date&.to_date
                date_range = "#{begin_date} - #{end_date}"

                row = [response_rate, measure, school, academic_year]

                all_grades = respondents.enrollment_by_grade.keys
                grades = "#{all_grades.first}-#{all_grades.last}"
                mutex.synchronize do
                  data << [measure.name,
                           measure.measure_id,
                           school.district.name,
                           school.name,
                           school.dese_id,
                           academic_year.range,
                           date_range,
                           grades,
                           student_score(row:),
                           student_zone(row:),
                           teacher_score(row:),
                           teacher_zone(row:),
                           admin_score(row:),
                           admin_zone(row:),
                           score.average,
                           zone]
                end
              end
            end
          end
        rescue ThreadError
        end
      end

      workers.each(&:join)

      csv = CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
    end

    def self.write_csv(data:, filepath:)
      File.write(filepath, csv)
    end

    def self.student_score(row:)
      row in [response_rate, measure, school, academic_year]
      student_score = measure.student_score(school:, academic_year:).average if response_rate.meets_student_threshold?
      student_score || "N/A"
    end

    def self.student_zone(row:)
      row in [response_rate, measure, school, academic_year]
      if response_rate.meets_student_threshold?
        student_zone = measure.student_zone(school:,
                                            academic_year:).type.to_s.capitalize
      end

      student_zone || "N/A"
    end

    def self.teacher_score(row:)
      row in [response_rate, measure, school, academic_year]
      teacher_score = measure.teacher_score(school:, academic_year:).average if response_rate.meets_teacher_threshold?

      teacher_score || "N/A"
    end

    def self.teacher_zone(row:)
      row in [response_rate, measure, school, academic_year]
      if response_rate.meets_teacher_threshold?
        teacher_zone = measure.teacher_zone(school:, academic_year:).type.to_s.capitalize
      end

      teacher_zone || "N/A"
    end

    def self.admin_score(row:)
      row in [response_rate, measure, school, academic_year]
      admin_score = measure.admin_score(school:, academic_year:).average
      admin_score = "N/A" unless admin_score.present? && admin_score >= 0
      admin_score
    end

    def self.admin_zone(row:)
      row in [response_rate, measure, school, academic_year]
      tmp_zone = measure.admin_zone(school:, academic_year:).type
      tmp_zone == :insufficient_data ? "N/A" : tmp_zone.to_s.capitalize
    end
  end
end
