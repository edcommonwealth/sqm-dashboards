require "#{Rails.root}/app/lib/seeder"

seeder = Seeder.new

seeder.seed_academic_years '2020-21', '2021-22'
seeder.seed_districts_and_schools Rails.root.join('data', 'qualtrics_district_and_school_code_key.csv')
seeder.seed_sqm_framework Rails.root.join('data', 'sqm_framework.csv')
