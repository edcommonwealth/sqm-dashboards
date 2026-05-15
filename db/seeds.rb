require "#{Rails.root}/app/lib/seeder"

seeder = Seeder.new

seeder.seed_academic_years "2016-17", "2017-18", "2018-19", "2019-20", "2020-21", "2021-22", "2022-23",
                           "2023-24",  "2024-25", "2025-26"
seeder.seed_districts_and_schools Rails.root.join("data", "master_list_of_schools_and_districts.csv")
seeder.seed_sqm_framework Rails.root.join("data", "sqm_framework.csv")
seeder.seed_demographics Rails.root.join("data", "demographics.csv")

Dir.glob(Rails.root.join("data", "enrollment", "*")).each do |filepath|
  seeder.seed_enrollment filepath
end
Dir.glob(Rails.root.join("data", "staffing", "staffing_count", "*")).each do |filepath|
  seeder.seed_staffing filepath
end
Dir.glob(Rails.root.join("data", "staffing", "esp_count", "*")).each do |filepath|
  seeder.seed_esp_counts filepath
end

Sftp::File.open(filepath: "/ecp/district_credentials.csv") do |file|
  seeder.seed_district_credentials file:
end
