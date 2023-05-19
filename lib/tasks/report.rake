namespace :report do
  desc 'create a report of the scores for all subcategories'
  task subcategory: :environment do
    Report::Subcategory.create_report(filename: 'ecp_subcategory_report.csv')
  end
end
