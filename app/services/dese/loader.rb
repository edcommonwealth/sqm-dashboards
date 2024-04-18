module Dese
  class Loader
    @memo = Hash.new
    def self.load_data(filepath:)
      admin_data_values = []
      @memo = Hash.new
      CSV.parse(File.read(filepath), headers: true) do |row|
        score = likert_score(row:)
        next unless valid_likert_score(likert_score: score)

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
      likert_score.round_up_to_one.round_down_to_five
    end

    def self.ay(row:)
      row['Academic Year'] || row['AcademicYear']
    end

    def self.dese_id(row:)
      row['DESE ID'] || row['Dese ID'] || row['Dese Id'] || row['School ID']
    end

    def self.admin_data_item(row:)
      row['Admin Data Item'] || row['Item ID'] || row['Item Id'] || row['Item  ID']
    end

    # these three methods do the memoization
    def self.find_school(dese_id:)
      return @memo["school"+dese_id] if @memo.key? "school"+dese_id
      @memo["school"+dese_id] ||= School.find_by_dese_id(dese_id.to_i)
    end
    def self.find_admin_data_item(admin_data_item_id:)
      return @memo["admin"+admin_data_item_id] if @memo.key? "admin"+admin_data_item_id
      @memo["admin"+admin_data_item_id] ||= AdminDataItem.find_by_admin_data_item_id(admin_data_item_id)
    end
    def self.find_ay(ay:)
      return @memo["year"+ay] if @memo.key? "year"+ay
      @memo["year"+ay] ||= AcademicYear.find_by_range(ay)
    end

    def self.create_admin_data_value(row:, score:)
      school = find_school(dese_id: dese_id(row:))
      admin_data_item_id = admin_data_item(row:)
      admin_data_item = find_admin_data_item(admin_data_item_id:)
      academic_year = find_ay(ay: ay(row:))

      return if school.nil?
      return if admin_data_item_id.nil? || admin_data_item_id.blank?

      admin_data_value = AdminDataValue.find_by(academic_year:, school:, admin_data_item:)

      if admin_data_value.present?
        admin_data_value.likert_score = score
        admin_data_value.save
        nil
      else
        AdminDataValue.new(
          likert_score: score,
          academic_year:,
          school:,
          admin_data_item:,
        )
      end
    end

    private_class_method :valid_likert_score
    private_class_method :likert_score
    private_class_method :ay
    private_class_method :dese_id
    private_class_method :admin_data_item
    private_class_method :create_admin_data_value
  end
end
