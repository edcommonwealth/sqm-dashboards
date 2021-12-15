require 'csv'

namespace :dupes do
  # produce CSV file that displays:
  # | district_name | school_name    | school_slug | created_at | updated_at |
  # | Dist1         | Jefferson High | jefferson-high | created_at | updated_at |
  # | Dist1         | Jefferson High | lincoln-high | created_at | updated_at |
  task record_csv: :environment do
    csv_string = CSV.generate do |csv|
      csv << ['District Name', 'School Name', 'School Slug', 'Creation Time', 'Updated Time']

      School.all.order(:district_id, :name, :created_at).each do |school|
        schools = School.where name: school.name, district: school.district
        if schools.length > 1
          csv << [school.district.name, school.name, school.slug, school.created_at.to_date, school.updated_at.to_date]
        end
      end
    end

    puts csv_string
  end

  task dedup_schools: :environment do
    School.all.each do |school|
      schools = School.where(name: school.name, district: school.district).order(:created_at)
      next unless schools.length > 1

      school_to_keep = schools.first
      schools.each do |school_to_destroy|
        next if school_to_destroy == school_to_keep

        school_to_keep.update(qualtrics_code: school_to_destroy.qualtrics_code)

        SurveyItemResponse.where(school: school_to_destroy).each do |response|
          success = response.update(school: school_to_keep)
          puts "Attempted to update survey item response with id #{response.id} to point to school with id #{school_to_keep.id}. Successful? #{success}"
          puts response.reload.school_id
        end

        school_to_destroy.destroy
      end
    end
  end
end
