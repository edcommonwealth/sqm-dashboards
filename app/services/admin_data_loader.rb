# frozen_string_literal: true

require 'csv'

class AdminDataLoader
  def self.load_data(filepath:)
    CSV.parse(File.read(filepath), headers: true) do |row|
      score = likert_score(row:)
      unless valid_likert_score(likert_score: score)
        puts "Invalid score: #{score}
        for school: #{School.find_by_dese_id(row['DESE ID']).name}
        admin data item #{admin_data_item(row:)} "
        next
      end
      create_admin_data_value(row:, score:)
    end
  end

  def self.valid_likert_score(likert_score:)
    likert_score >= 1 && likert_score <= 5
  end

  def self.likert_score(row:)
    likert_score = row['LikertScore'] || row['Likert Score'] || row['Likert_Score']
    likert_score = likert_score.to_f
    likert_score = 1 if likert_score.positive? && likert_score < 1
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
    admin_data_value = AdminDataValue.new
    admin_data_value.likert_score = score
    admin_data_value.academic_year = AcademicYear.find_by_range ay(row:)
    admin_data_value.school = School.find_by_dese_id dese_id(row:).to_i
    admin_data_value.admin_data_item = AdminDataItem.find_by_admin_data_item_id admin_data_item(row:)
    admin_data_value.save!
  end

  private_class_method :valid_likert_score
end
