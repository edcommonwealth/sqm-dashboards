module Report
  class MeasureByGrade
    def self.create_report(schools:, academic_years: AcademicYear.all, measures: ::Measure.all.order(measure_id: :ASC), filename: "measure_by_grade.csv")
      data = to_csv(schools:, academic_years:, measures:)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data: data, filepath: filepath)
      data
    end

    def self.to_csv(schools:, academic_years:, measures:)
      headers = ["Measure Name", "Measure ID", "Academic Year", "Averages - ALL MCIEA Schools - Student + Teacher + Admin", "Averages - ALL MCIEA Schools - Students only"]
      grades = (0..12).to_a.map(&:to_s).map { |grade| grade == "0" ? "Kindergarten" : "Grade #{grade}" }
      headers.concat(grades)

      CSV.generate(headers: true) do |csv|
        csv << headers
        academic_years.each do |academic_year|
          measures.each do |measure|
            scores = schools.map do |school|
              measure.score(school:, academic_year:).average
            end.remove_blanks

            avg_score = scores.count.positive? ? scores.average : nil
            avg_score = avg_score.round(2) unless avg_score.nil?
            avg_score = "N/A" if avg_score.nil?

            student_scores = schools.map do |school|
              measure.student_score(school:, academic_year:).average
            end.remove_blanks

            student_avg = student_scores.count.positive? ? student_scores.average : nil
            student_avg = student_avg.round(2) unless student_avg.nil?
            student_avg = "N/A" if student_avg.nil?

            tmp1 = [
              measure.name,
              measure.measure_id,
              academic_year.range,
              avg_score,
              student_avg
            ]

            tmp2 = (0..12).to_a.map do |grade|
              s_averages = schools.each.map do |school|
                next unless StudentResponseRateCalculator.new(subcategory: measure.subcategory, school:, academic_year:).meets_student_threshold?

                student_survey_items = ::SurveyItem.where(id: ::SurveyItem.joins("inner join survey_item_responses on survey_item_responses.survey_item_id = survey_items.id")
                                .student_survey_items
                                .where("survey_item_responses.school": school,
                                       "survey_item_responses.academic_year": academic_year,
                                       "survey_item_responses.survey_item_id": measure.student_survey_items,
                                       "survey_item_responses.grade": grade)
                                .group("survey_items.id")
                                .having("count(*) >= 10")
                                .count.keys)

                ::SurveyItemResponse.where(survey_item: student_survey_items, school:, academic_year:, grade:).average(:likert_score)
              end.remove_blanks.average

              if s_averages.positive?
                s_averages.round(2)
              else
                "N/A"
              end
            end

            csv << tmp1.concat(tmp2)
          end
        end
      end
    end

    def self.write_csv(data:, filepath:)
      File.write(filepath, data)
    end

    def self.run(filepath: Rails.root.join("tmp", "exports", "measure_by_grade", "measure_by_grade.csv"))
      data = to_csv(schools: ::School.all, academic_years: ::AcademicYear.all, measures: ::Measure.all)
      write_csv(data:, filepath:)
    end
  end
end
