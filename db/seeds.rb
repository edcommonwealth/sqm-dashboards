require "#{Rails.root}/app/lib/seeder"

seeder = Seeder.new

seeder.seed_academic_years '2016-17', '2017-18', '2018-19', '2019-20', '2020-21', '2021-22', '2022-23'
seeder.seed_districts_and_schools Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
seeder.seed_surveys Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
seeder.seed_respondents Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
seeder.seed_sqm_framework Rails.root.join('data', 'sqm_framework.csv')
seeder.seed_demographics Rails.root.join('data', 'demographics.csv')

Dir.glob(Rails.root.join('data', 'enrollment', '*')).each do |file|
  seeder.seed_enrollment(file)
end
