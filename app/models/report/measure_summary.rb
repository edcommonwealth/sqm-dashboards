module Report
  class MeasureSummary
    def self.create_report(schools:, academic_years: AcademicYear.all, measures: ::Measure.all.order(measure_id: :ASC), filename: "measure_summary.csv")
      data = to_csv(schools:, academic_years:, measures:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.to_csv(schools:, academic_years:, measures:)
      data = []
      mutex = Thread::Mutex.new
      data << ["Measure Name", "Measure ID", "District", "Academic Year", "Recorded Date Range", "Grades", "Student Score", "Student Zone", "Teacher Score",
               "Teacher Zone", "Admin Score", "Admin Zone", "All Score (Average)", "All Score Zone"]
      pool_size = 2
      jobs = Queue.new
      measures.each { |measure| jobs << measure }

      workers = pool_size.times.map do
        Thread.new do
          while measure = jobs.pop(true)
            all_grades = Respondent.grades_that_responded_to_survey(academic_year: academic_years, school: schools)
            grades = "#{all_grades.first}-#{all_grades.last}"
            district = schools.first.district

            academic_years.each do |academic_year|
              begin_date = ::SurveyItemResponse.where(school: schools,
                                                      academic_year:).where.not(recorded_date: nil).order(:recorded_date).first&.recorded_date&.to_date
              end_date = ::SurveyItemResponse.where(school: schools,
                                                    academic_year:).where.not(recorded_date: nil).order(:recorded_date).last&.recorded_date&.to_date
              date_range = "#{begin_date} - #{end_date}"

              row = [measure, district, academic_year]

              mutex.synchronize do
                data << [measure.name,
                         measure.measure_id,
                         district.name,
                         academic_year.range,
                         date_range,
                         grades,
                         student_score(row:),
                         student_zone(row:),
                         teacher_score(row:),
                         teacher_zone(row:),
                         admin_score(row:),
                         admin_zone(row:),
                         all_data_score(row:),
                         all_data_zone(row:)]
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
      File.write(filepath, csv)
    end

    def self.all_data_score(row:)
      row in [ measure, district, academic_year]
      score = district.schools.map do |school|
        score = measure.score(school:, academic_year:).average
      end.remove_blanks.average
      score || "N/A"
    end

    def self.all_data_zone(row:)
      row in [ measure, district, academic_year]

      average = all_data_score(row:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)
      student_zone = measure.zone_for_score(score:).type.to_s

      student_zone || "N/A"
    end

    def self.student_score(row:)
      row in [ measure, district, academic_year]
      student_score = district.schools.map do |school|
        student_score = measure.student_score(school:, academic_year:).average
      end.remove_blanks.average
      student_score || "N/A"
    end

    def self.student_zone(row:)
      row in [ measure, district, academic_year]
      average = student_score(row:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)
      student_zone = measure.zone_for_score(score:).type.to_s

      student_zone || "N/A"
    end

    def self.teacher_score(row:)
      row in [ measure, district, academic_year]
      teacher_score = district.schools.map do |school|
        measure.teacher_score(school:, academic_year:).average
      end.remove_blanks.average

      teacher_score || "N/A"
    end

    def self.teacher_zone(row:)
      row in [ measure, district, academic_year]
      average = teacher_score(row:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)
      teacher_zone = measure.zone_for_score(score:).type.to_s

      teacher_zone || "N/A"
    end

    def self.admin_score(row:)
      row in [ measure, district, academic_year]
      admin_score = district.schools.map do |school|
        measure.admin_score(school:, academic_year:).average
      end.remove_blanks.average

      admin_score = "N/A" unless admin_score.present? && admin_score >= 0
      admin_score
    end

    def self.admin_zone(row:)
      row in [ measure, district, academic_year]
      average = admin_score(row:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)

      tmp_zone = measure.zone_for_score(score:).type.to_s
      tmp_zone == :insufficient_data ? "N/A" : tmp_zone.to_s.capitalize
    end
  end
end
