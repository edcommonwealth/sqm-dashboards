# frozen_string_literal: true

class AdminDataLoader
  def self.load_data(filepath:)
    admin_data_values = []
    CSV.parse(File.read(filepath), headers: true) do |row|
      score = likert_score(row:)
      unless valid_likert_score(likert_score: score)
        puts "Invalid score: #{score}
        for school: #{School.find_by_dese_id(row['DESE ID']).name}
        admin data item #{admin_data_item(row:)} "
        next
      end
      admin_data_values << create_admin_data_value(row:, score:)
    end

    AdminDataValue.import(admin_data_values.flatten.compact, on_duplicate_key_update: :all)
  end

  private

  def self.valid_likert_score(likert_score:)
    likert_score >= 1 && likert_score <= 5
  end

  def self.likert_score(row:)
    likert_score = (row['LikertScore'] || row['Likert Score'] || row['Likert_Score']).to_f
    likert_score = round_up_to_one(likert_score:)
    round_down_to_five(likert_score:)
  end

  def self.round_up_to_one(likert_score:)
    likert_score = 1 if likert_score.positive? && likert_score < 1
    likert_score
  end

  def self.round_down_to_five(likert_score:)
    likert_score = 5 if likert_score > 5
    likert_score
  end

  def self.ay(row:)
    row['Academic Year'] || row['AcademicYear']
  end

  def self.dese_id(row:)
    row['DESE ID'] || row['Dese ID'] || row['Dese Id']
  end

  def self.admin_data_item(row:)
    row['Item ID'] || row['Item Id']
  end

  def self.create_admin_data_value(row:, score:)
    admin_data_value = AdminDataValue.find_or_initialize_by(school: School.find_by_dese_id(dese_id(row:).to_i),
                                                            academic_year: AcademicYear.find_by_range(ay(row:)),
                                                            admin_data_item: AdminDataItem.find_by_admin_data_item_id(admin_data_item(row:)))
    return nil if admin_data_value.likert_score == score

    admin_data_value.likert_score = score
    admin_data_value
  end

  private_class_method :valid_likert_score
  private_class_method :likert_score
  private_class_method :round_up_to_one
  private_class_method :ay
  private_class_method :dese_id
  private_class_method :admin_data_item
  private_class_method :create_admin_data_value
end
