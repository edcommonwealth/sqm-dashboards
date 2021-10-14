require 'csv'

namespace :dupes do
  task record_csv: :environment do
    csv_string = CSV.generate do |csv|
      csv << [ 'District Name', 'School Name', 'School Slug', 'Creation Time', 'Updated Time' ]

      School.all.order(:district_id, :name, :created_at).each do |school|
        schools = School.where name: school.name, district: school.district
        if schools.length > 1
          csv << [school.district.name, school.name, school.slug, school.created_at.to_date, school.updated_at.to_date]
        end
      end
    end

    puts csv_string
  end
end

# produce CSV file that displays:
    # | district_name | school_name    | school_slug | created_at | updated_at |
    # | Dist1         | Jefferson High | jefferson-high | created_at | updated_at |
    # | Dist1         | Jefferson High | lincoln-high | created_at | updated_at |
