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

            academic_years.each do |academic_year|
              schools.flat_map(&:district).uniq.each do |district|
                selected_schools = district.schools
                begin_date = ::SurveyItemResponse.where(school: selected_schools,
                                                        academic_year:).where.not(recorded_date: nil).order(:recorded_date).first&.recorded_date&.to_date
                end_date = ::SurveyItemResponse.where(school: selected_schools,
                                                      academic_year:).where.not(recorded_date: nil).order(:recorded_date).last&.recorded_date&.to_date
                date_range = "#{begin_date} - #{end_date}"

                mutex.synchronize do
                  data << [measure.name,
                           measure.measure_id,
                           district.name,
                           academic_year.range,
                           date_range,
                           grades,
                           student_score(measure:,  schools: selected_schools, academic_year:),
                           student_zone(measure:,   schools: selected_schools, academic_year:),
                           teacher_score(measure:,  schools: selected_schools, academic_year:),
                           teacher_zone(measure:,   schools: selected_schools, academic_year:),
                           admin_score(measure:,    schools: selected_schools, academic_year:),
                           admin_zone(measure:,     schools: selected_schools, academic_year:),
                           all_data_score(measure:, schools: selected_schools, academic_year:),
                           all_data_zone(measure:,  schools: selected_schools, academic_year:)]
                end
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

    def self.all_data_score(measure:, schools:, academic_year:)
      @all_data_score ||= Hash.new do |memo, (measure, schools, academic_year)|
        score = schools.map do |school|
          score = measure.score(school:, academic_year:).average
        end.remove_blanks.average
        memo[[measure, schools, academic_year]] = score || "N/A"
      end
      @all_data_score[[measure, schools, academic_year]]
    end

    def self.all_data_zone(measure:, schools:, academic_year:)
      average = all_data_score(measure:, schools:, academic_year:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)
      student_zone = measure.zone_for_score(score:).type.to_s

      student_zone || "N/A"
    end

    def self.student_score(measure:, schools:, academic_year:)
      @student_score ||= Hash.new do |memo, (measure, schools, academic_year)|
        student_score = schools.map do |school|
          student_score = measure.student_score(school:, academic_year:).average
        end.remove_blanks.average
        memo[[measure, schools, academic_year]] = student_score || "N/A"
      end
      @student_score[[measure, schools, academic_year]]
    end

    def self.student_zone(measure:, schools:, academic_year:)
      average = student_score(measure:, schools:, academic_year:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)
      student_zone = measure.zone_for_score(score:).type.to_s

      student_zone || "N/A"
    end

    def self.teacher_score(measure:, schools:, academic_year:)
      @teacher_score ||= Hash.new do |memo, (measure, schools, academic_year)|
        teacher_score = schools.map do |school|
          measure.teacher_score(school:, academic_year:).average
        end.remove_blanks.average

        memo[[measure, schools, academic_year]] = teacher_score || "N/A"
      end
      @teacher_score[[measure, schools, academic_year]]
    end

    def self.teacher_zone(measure:, schools:, academic_year:)
      average = teacher_score(measure:, schools:, academic_year:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)
      teacher_zone = measure.zone_for_score(score:).type.to_s

      teacher_zone || "N/A"
    end

    def self.admin_score(measure:, schools:, academic_year:)
      @admin_score ||= Hash.new do |memo, (measure, schools, academic_year)|
        admin_score = schools.map do |school|
          measure.admin_score(school:, academic_year:).average
        end.remove_blanks.average

        admin_score = "N/A" unless admin_score.present? && admin_score >= 0
        memo[[measure, schools, academic_year]] = admin_score
      end
      @admin_score[[measure, schools, academic_year]]
    end

    def self.admin_zone(measure:, schools:, academic_year:)
      average = admin_score(measure:, schools:, academic_year:)
      score = Score.new(average:, meets_teacher_threshold: true, meets_student_threshold: true,
                        meets_admin_data_threshold: true)

      tmp_zone = measure.zone_for_score(score:).type.to_s
      tmp_zone == :insufficient_data ? "N/A" : tmp_zone.to_s.capitalize
    end
  end
end
