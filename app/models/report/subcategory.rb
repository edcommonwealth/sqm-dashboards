module Report
  class Subcategory
    def self.create_report(schools: School.all, academic_years: AcademicYear.all, subcategories: ::Subcategory.all)
      data = []
      data << ['School', 'Academic Year', 'Subcategory', 'Student Score', 'Student Zone', 'Teacher Score',
               'Teacher Zone', 'Admin Score', 'Admin Zone', 'All Score (Average)', 'All Score Zone']
      schools.each do |school|
        academic_years.each do |academic_year|
          next if SurveyItemResponse.where(school:, academic_year:).count.zero?

          subcategories.each do |subcategory|
            student_score = subcategory.student_score(school:, academic_year:)
            student_zone = subcategory.student_zone(school:, academic_year:).type.to_s.capitalize
            teacher_score = subcategory.teacher_score(school:, academic_year:)
            teacher_zone = subcategory.teacher_zone(school:, academic_year:).type.to_s.capitalize
            admin_score = subcategory.admin_score(school:, academic_year:)
            admin_zone = subcategory.admin_zone(school:, academic_year:).type.to_s.capitalize
            score = subcategory.score(school:, academic_year:)
            zone = subcategory.zone(school:, academic_year:).type.to_s.capitalize

            data << [school.name, academic_year.range, subcategory.subcategory_id,
                     student_score, student_zone, teacher_score, teacher_zone, admin_score, admin_zone, score, zone]
          end
        end
      end

      FileUtils.mkdir_p Rails.root.join('tmp', 'reports')
      filepath = Rails.root.join('tmp', 'reports', 'subcategories.csv')
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
