namespace :report do
  desc 'create a report of the scores for all subcategories'
  task subcategory: :environment do
    Report::Subcategory.create_report(filename: 'rpp_subcategory_report.csv')
  end

  namespace :skipped do
    desc 'report skipped questions'
    task standard: :environment do
      schools = School.all
      percent_differences = []
      output = []
      survey_items = SurveyItem.standard_survey_items
      academic_year = AcademicYear.all
      academic_year.each do |academic_year|
        survey_items.each do |survey_item|
          schools.each do |school|
            percent_differences << SurveyItem.difference_from_mean(school:,
                                                                   academic_year:, survey_items:, survey_item_id: survey_item.id)
          end
          output << [academic_year.range, survey_item.survey_item_id, percent_differences.compact.average]
          percent_differences = []
        end
      end
      pp output
      output
    end
  end
end
