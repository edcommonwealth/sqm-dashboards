namespace :one_off do
  desc "list survey_items that have no survey responses by district"
  task list_survey_items_that_lack_responses: :environment do
    output = AcademicYear.all.map do |academic_year|
      District.all.map do |district|
        SurveyItem.all.map do |survey_item|
          [academic_year.range, survey_item.survey_item_id,
           survey_item.survey_item_responses.joins(:school).where("school.district": district, academic_year:).count, district.name]
        end
      end
    end

    output = output.map do |year|
      year.map do |district|
        district.reject do |survey_item|
          survey_item[2] > 0 || survey_item[1].starts_with?("a-")
        end
      end
    end
    pp output
  end

  desc "list the most recent admin data values"
  task list_recent_admin_data_values: :environment do
    range = 4.weeks.ago..1.second.ago
    values = AdminDataValue.where(updated_at: range).group(:admin_data_item).count.map do |item|
      [item[0].admin_data_item_id, item[0].scale.measure.measure_id]
    end
    puts values
  end

  desc "change dese id of Minot Forest Elementary School"
  task change_dese_id: :environment do
    school = School.find_by_name "Minot Forest Elementary School"
    school.dese_id = 310_001_799
    school.save

    school = School.find_by_name "Wareham Elementary School"
    school.slug = school.name.parameterize
    school.dese_id = 310_001_7
    school.save
  end

  desc "delete measures we don't want to show"
  task delete_library_measure: :environment do
    measure = Measure.find_by_measure_id("3B-iv")
    measure.scales.each { |scale| scale.survey_items.each { |survey_item| survey_item.delete } }
    measure.scales.each { |scale| scale.delete }
    measure.delete
  end

  desc "delete last year of respondent data and reseed numbers"
  task reseed_respondents: :environment do
    Respondent.delete_all

    seeder = Seeder.new
    seeder.seed_enrollment Rails.root.join("data", "enrollment", "enrollment.csv")
    seeder.seed_enrollment Rails.root.join("data", "enrollment", "nj_enrollment.csv")
    seeder.seed_enrollment Rails.root.join("data", "enrollment", "wi_enrollment.csv")
    seeder.seed_staffing Rails.root.join("data", "staffing", "staffing.csv")
    seeder.seed_staffing Rails.root.join("data", "staffing", "nj_staffing.csv")
    seeder.seed_staffing Rails.root.join("data", "staffing", "wi_staffing.csv")
    seeder.seed_esp_counts Rails.root.join("data", "staffing", "esp_counts.csv")
  end

  desc "delete 2023-24 AcademicYear and all responses, admin data, enrollment numbers and staffing numbers"
  task delete_2023_24: :environment do
    academic_years = ["2023-24", "2023-24 Fall", "2023-24 Spring"]
    academic_years.each do |ay|
      academic_year = AcademicYear.find_by_range ay
      next unless academic_year.present?

      AdminDataValue.where(academic_year:).delete_all
      Respondent.where(academic_year:).delete_all
      SurveyItemResponse.where(academic_year:).delete_all
      academic_year.delete
    end
  end
  desc "delete all student records incorrectly created by teacher responses"
  task delete_errant_student_records: :environment do
    wrong_response_ids = SurveyItemResponse.where(survey_item: SurveyItem.teacher_survey_items).pluck(:response_id).uniq
    student_response_ids = SurveyItemResponse.where(response_id: wrong_response_ids,
                                                    survey_item: SurveyItem.student_survey_items).pluck(:response_id).uniq
    wrong_response_ids -= student_response_ids

    SurveyItemResponse.where(response_id: wrong_response_ids).update_all(student_id: nil)
    StudentRace.where(student: Student.where(response_id: wrong_response_ids)).delete_all
    Student.where(response_id: wrong_response_ids).delete_all
  end

  desc "print out percentage of nil values for range"
  task nil_grades: :environment do
    AcademicYear.all.each do |academic_year|
      School.all.each do |school|
        total = SurveyItemResponse.where(school:, academic_year:,
                                         survey_item: SurveyItem.student_survey_items).count.to_f

        respondent_count = SurveyItemResponse.where(school:, academic_year:,
                                                    survey_item: SurveyItem.student_survey_items).pluck(:response_id).uniq.count.to_f
        nil_count = SurveyItemResponse.where(school:, academic_year:, grade: nil,
                                             survey_item: SurveyItem.student_survey_items).count
        percentage = ((nil_count / total) * 100).round(1)
        if percentage > 10
          puts "#{percentage}% nil grades out of #{respondent_count} students responding for:  #{school.name}, #{academic_year.range}"
        end
      end
    end
  end
end
