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
end
