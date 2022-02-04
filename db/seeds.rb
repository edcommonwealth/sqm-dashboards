require "#{Rails.root}/app/lib/seeder"

seeder = Seeder.new

seeder.seed_academic_years '2020-21', '2019-20'
seeder.seed_districts_and_schools Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
seeder.seed_respondents Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
seeder.seed_sqm_framework Rails.root.join('data', 'sqm_framework.csv')
