module Report
  class Subcategory
    def self.create_report(schools: School.all.includes(:district), academic_years: AcademicYear.all, subcategories: ::Subcategory.all, filename: 'subcategories.csv')
      data = []
      mutex = Thread::Mutex.new
      data << ['District', 'School', 'School Code', 'Academic Year', 'Recorded Date Range', 'Grades', 'Subcategory', 'Student Score', 'Student Zone', 'Teacher Score',
               'Teacher Zone', 'Admin Score', 'Admin Zone', 'All Score (Average)', 'All Score Zone']
      pool_size = 2
      jobs = Queue.new
      schools.each { |school| jobs << school }

      workers = pool_size.times.map do
        Thread.new do
          while school = jobs.pop(true)
            academic_years.each do |academic_year|
              subcategories.each do |subcategory|
                respondents = Respondent.find_by(school:, academic_year:)
                next if respondents.nil?

                response_rate = subcategory.response_rate(school:, academic_year:)
                next unless response_rate.meets_student_threshold? || response_rate.meets_teacher_threshold?

                score = subcategory.score(school:, academic_year:)
                zone = subcategory.zone(school:, academic_year:).type.to_s.capitalize

                begin_date = SurveyItemResponse.where(school:,
                                                      academic_year:).where.not(recorded_date: nil).order(:recorded_date).first&.recorded_date&.to_date
                end_date = SurveyItemResponse.where(school:,
                                                    academic_year:).where.not(recorded_date: nil).order(:recorded_date).last&.recorded_date&.to_date
                date_range = "#{begin_date} - #{end_date}"

                row = [response_rate, subcategory, school, academic_year]

                all_grades = respondents.counts_by_grade.keys
                grades = "#{all_grades.first}-#{all_grades.last}"
                mutex.synchronize do
                  data << [school.district.name,
                           school.name,
                           school.dese_id,
                           academic_year.range,
                           date_range,
                           grades,
                           subcategory.subcategory_id,
                           student_score(row:),
                           student_zone(row:),
                           teacher_score(row:),
                           teacher_zone(row:),
                           admin_score(row:),
                           admin_zone(row:),
                           score,
                           zone]
                end
              end
            end
          end
        rescue ThreadError
        end
      end

      workers.each(&:join)
      FileUtils.mkdir_p Rails.root.join('tmp', 'reports')
      filepath = Rails.root.join('tmp', 'reports', filename)
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

    def self.student_score(row:)
      row in [response_rate, subcategory, school, academic_year]
      student_score = subcategory.student_score(school:, academic_year:) if response_rate.meets_student_threshold?
      student_score || 'N/A'
    end

    def self.student_zone(row:)
      row in [response_rate, subcategory, school, academic_year]
      if response_rate.meets_student_threshold?
        student_zone = subcategory.student_zone(school:,
                                                academic_year:).type.to_s.capitalize
      end

      student_zone || 'N/A'
    end

    def self.teacher_score(row:)
      row in [response_rate, subcategory, school, academic_year]
      teacher_score = subcategory.teacher_score(school:, academic_year:) if response_rate.meets_teacher_threshold?

      teacher_score || 'N/A'
    end

    def self.teacher_zone(row:)
      row in [response_rate, subcategory, school, academic_year]
      if response_rate.meets_teacher_threshold?
        teacher_zone = subcategory.teacher_zone(school:, academic_year:).type.to_s.capitalize
      end

      teacher_zone || 'N/A'
    end

    def self.admin_score(row:)
      row in [response_rate, subcategory, school, academic_year]
      admin_score = subcategory.admin_score(school:, academic_year:)
      admin_score = 'N/A' unless admin_score >= 0
      admin_score
    end

    def self.admin_zone(row:)
      row in [response_rate, subcategory, school, academic_year]
      tmp_zone = subcategory.admin_zone(school:, academic_year:).type
      tmp_zone == :insufficient_data ? 'N/A' : tmp_zone.to_s.capitalize
    end
  end
end
