module Dese
  class Loader
    def self.load_data(filepath:)
      admin_data_values = []
      CSV.parse(File.read(filepath), headers: true) do |row|
        score = likert_score(row:)
        unless valid_likert_score(likert_score: score)
          # school = School.find_by_dese_id(row['DESE ID']) || School.new(name: 'School not in consortium',
          #                                                               dese_id: row['DESE ID'])
          # puts "Invalid score: #{score}
          # for school: #{school.name}
          # admin data item #{admin_data_item(row:)} "
          next
        end

        admin_data_values << create_admin_data_value(row:, score:)
      end

      AdminDataValue.import(admin_data_values.flatten.compact, batch_size: 1_000, on_duplicate_key_update: :all)
    end

    private

    def self.valid_likert_score(likert_score:)
      likert_score >= 1 && likert_score <= 5
    end

    def self.likert_score(row:)
      likert_score = (row['Likert Score'] || row['LikertScore'] || row['Likert_Score']).to_f
      round_up_to_one(likert_score:)
    end

    def self.round_up_to_one(likert_score:)
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
      row['Admin Data Item'] || row['Item ID'] || row['Item Id']
    end

    def self.create_admin_data_value(row:, score:)
      school = School.find_by_dese_id(dese_id(row:).to_i)
      admin_data_item_id = admin_data_item(row:)

      return if school.nil?
      return if admin_data_item_id.nil? || admin_data_item_id.blank?

      admin_data_value = AdminDataValue.find_by(academic_year: AcademicYear.find_by_range(ay(row:)),
                                                school:,
                                                admin_data_item: AdminDataItem.find_by_admin_data_item_id(admin_data_item_id))
      if admin_data_value.present?
        admin_data_value.likert_score = score
        admin_data_value.save
        nil
      else
        AdminDataValue.new(
          likert_score: score,
          academic_year: AcademicYear.find_by_range(ay(row:)),
          school:,
          admin_data_item: AdminDataItem.find_by_admin_data_item_id(admin_data_item(row:))
        )
      end
    end

    private_class_method :valid_likert_score
    private_class_method :likert_score
    private_class_method :round_up_to_one
    private_class_method :ay
    private_class_method :dese_id
    private_class_method :admin_data_item
    private_class_method :create_admin_data_value
  end
end
