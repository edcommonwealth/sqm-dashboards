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

    facilities_and_personnel = Subcategory.find_by name: 'Facilities and Personnel', subcategory_id: 'default-subcategory-id'
    if facilities_and_personnel.present?
      facilities_and_personnel.destroy
      puts "number of outstanding subcategories now: #{Subcategory.where(subcategory_id: 'default-subcategory-id').count}"
    end
  end
end
