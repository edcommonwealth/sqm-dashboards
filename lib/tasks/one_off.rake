namespace :one_off do
  task remove_dupes: :environment do
    SurveyItemResponse.delete_all
    SurveyItem.delete_all
    AdminDataItem.delete_all
    Measure.delete_all

    csv_file = Rails.root.join('data', 'sqm_framework.csv')
    CSV.parse(File.read(csv_file), headers: true) do |row|
      category_name = row['Category'].strip
      category_id = row['Category ID'].strip

      category = SqmCategory.find_by!(name: category_name)
      category.update! category_id: category_id

      subcategory_name = row['Subcategory'].strip
      subcategory_id = row['Subcategory ID'].strip
      subcategory = Subcategory.find_by! name: subcategory_name, sqm_category: category
      subcategory.update! subcategory_id: subcategory_id
    end

    puts "number of outstanding categories: #{SqmCategory.where(category_id: 'default-category-id').count}"
    puts "number of outstanding subcategories: #{Subcategory.where(subcategory_id: 'default-subcategory-id').count}"

    facilities_and_personnel = Subcategory.find_by name: 'Facilities and Personnel',
                                                   subcategory_id: 'default-subcategory-id'
    if facilities_and_personnel.present?
      facilities_and_personnel.destroy
      puts "number of outstanding subcategories now: #{Subcategory.where(subcategory_id: 'default-subcategory-id').count}"
    end
  end

  task add_dese_ids: :environment do
    all_schools = School.all.includes(:district)
    updated_schools = []

    qualtrics_schools = {}

    csv_file = Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
    CSV.parse(File.read(csv_file), headers: true) do |row|
      district_id = row['District Code'].to_i
      school_id = row['School Code'].to_i

      if qualtrics_schools[[district_id, school_id]].present?
        puts "Duplicate entry row #{row}"
        next
      end

      qualtrics_schools[[district_id, school_id]] = row
    end

    qualtrics_schools.each do |(district_id, school_id), csv_row|
      school = all_schools.find do |school|
        school.qualtrics_code == school_id && school.district.qualtrics_code == district_id
      end

      if school.nil?
        school_name = csv_row['School Name'].strip
        puts "Could not find school '#{school_name}' with district id: #{district_id}, school id: #{school_id}"
        potential_school_ids = School.where('name like ?', "%#{school_name}%").map(&:id)
        puts "Potential ID matches: #{potential_school_ids}" if potential_school_ids.present?
        next
      end

      school.update!(dese_id: csv_row['DESE School ID'])
      updated_schools << school.id
    end

    School.where.not(id: updated_schools).each {|school| puts "School with unchanged DESE id: #{school.name}, id: #{school.id}"}
  end
end
