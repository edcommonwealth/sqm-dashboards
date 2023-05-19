module Report
  class Subcategory
    def self.create_report(schools: School.all, academic_years: AcademicYear.all, subcategories: ::Subcategory.all, filename: "subcategories.csv")
      data = []
      data << ["School", "Academic Year", "Subcategory", "Student Score", "Student Zone", "Teacher Score",
        "Teacher Zone", "Admin Score", "Admin Zone", "All Score (Average)", "All Score Zone"]
      schools.each do |school|
        academic_years.each do |academic_year|
          subcategories.each do |subcategory|
            next if Respondent.where(school:, academic_year:).empty?

            response_rate = subcategory.response_rate(school:, academic_year:)
            next unless response_rate.meets_student_threshold? || response_rate.meets_teacher_threshold?

            score = subcategory.score(school:, academic_year:)
            zone = subcategory.zone(school:, academic_year:).type.to_s.capitalize

            row = [response_rate, subcategory, school, academic_year]
            data << [school.name,
              academic_year.range,
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

    def self.student_score(row:)
      row in [response_rate, subcategory, school, academic_year]
      student_score = subcategory.student_score(school:, academic_year:) if response_rate.meets_student_threshold?
      student_score || "N/A"
    end

    def self.student_zone(row:)
      row in [response_rate, subcategory, school, academic_year]
      if response_rate.meets_student_threshold?
        student_zone = subcategory.student_zone(school:,
          academic_year:).type.to_s.capitalize
      end

      student_zone || "N/A"
    end

    def self.teacher_score(row:)
      row in [response_rate, subcategory, school, academic_year]
      teacher_score = subcategory.teacher_score(school:, academic_year:) if response_rate.meets_teacher_threshold?

      teacher_score || "N/A"
    end

    def self.teacher_zone(row:)
      row in [response_rate, subcategory, school, academic_year]
      if response_rate.meets_teacher_threshold?
        teacher_zone = subcategory.teacher_zone(school:, academic_year:).type.to_s.capitalize
      end

      teacher_zone || "N/A"
    end

    def self.admin_score(row:)
      row in [response_rate, subcategory, school, academic_year]
      admin_score = subcategory.admin_score(school:, academic_year:)
      admin_score = "N/A" unless admin_score >= 0
      admin_score
    end

    def self.admin_zone(row:)
      row in [response_rate, subcategory, school, academic_year]
      tmp_zone = subcategory.admin_zone(school:, academic_year:).type
      (tmp_zone == :insufficient_data) ? "N/A" : tmp_zone.to_s.capitalize
    end
  end
end
