module Report
  class MeasureByGrade
    def self.create_report(schools:, academic_years: AcademicYear.all, measures: ::Measure.all.order(measure_id: :ASC), filename: "measure_by_grade.csv")
      data = to_csv(schools:, academic_years:, measures:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.to_csv(schools:, academic_years:, measures:)
      ::School.all.map do |school|
        ::AcademicYear.all.map do |academic_year|
          ::Measure.all.map do |measure|
            next 0 if measure.student_survey_items.count.zero?

            measure.student_survey_items.map do |survey_item|
              ::SurveyItemResponse.where(survey_item:, school: school, academic_year: academic_year).average(:likert_score).to_f.round(2)
            end.remove_blanks.average
          end
        end
      end
    end

    def self.write_csv(data:, filepath:)
      File.write(filepath, csv)
    end
  end
end
