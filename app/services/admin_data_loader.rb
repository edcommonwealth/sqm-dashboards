require 'csv'

class AdminDataLoader
  def self.load_data(filepath:)
    CSV.parse(File.read(filepath), headers: true) do |row|
      likert_score = row['LikertScore'] || row['Likert Score'] || row['Likert_Score']
      likert_score = likert_score.to_f
      likert_score = 1 if likert_score > 0 && likert_score < 1

      unless valid_likert_score(likert_score:)
        puts "This value is not valid #{likert_score}"
        next
      end

      ay = row['Academic Year'] || row['AcademicYear']
      dese_id = row['DESE ID'] || row['Dese ID'] || row['Dese Id']
      admin_data_item_id = row['Item ID'] || row['Item Id']
      admin_data_value = AdminDataValue.new
      admin_data_value.likert_score = likert_score
      admin_data_value.academic_year = AcademicYear.find_by_range ay
      admin_data_value.school = School.find_by_dese_id dese_id.to_i
      admin_data_value.admin_data_item = AdminDataItem.find_by_admin_data_item_id admin_data_item_id
      admin_data_value.save!
    end
  end

  def self.valid_likert_score(likert_score:)
    likert_score >= 1 && likert_score <= 5
  end

  private_class_method :valid_likert_score
end
