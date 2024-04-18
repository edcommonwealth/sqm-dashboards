module Dese
  class Loader
    @memo = {}
    def self.load_data(filepath:)
      admin_data_values = []
      @memo = {}
      schools = School.by_dese_id
      CSV.parse(File.read(filepath), headers: true) do |row|
        score = likert_score(row:)
        next unless valid_likert_score(likert_score: score)

        values = create_admin_data_value(row:, score:, schools:)
        admin_data_values.concat(values) if values
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

    # these two methods do the memoization
    def self.find_admin_data_item(admin_data_item_id:)
      return @memo["admin" + admin_data_item_id] if @memo.key?("admin" + admin_data_item_id)

      @memo["admin" + admin_data_item_id] ||= AdminDataItem.find_by_admin_data_item_id(admin_data_item_id)
    end

    def self.find_ays(ay:)
      return @memo["year" + ay] if @memo.key?("year" + ay)

      @memo["year" + ay] ||= AcademicYear.of_year(ay)
    end

    def self.create_admin_data_value(row:, score:, schools:)
      school = schools[dese_id(row:).to_i]
      admin_data_item_id = admin_data_item(row:)
      admin_data_item = find_admin_data_item(admin_data_item_id:)
      academic_years = find_ays(ay: ay(row:))

      return if school.nil?
      return if admin_data_item_id.nil? || admin_data_item_id.blank?
      return unless academic_years.size.positive?

      out = []
      academic_years.each do |academic_year|
        admin_data_value = AdminDataValue.find_by(academic_year:, school:, admin_data_item:)

        if admin_data_value.present?
          admin_data_value.likert_score = score
          admin_data_value.save
          []
        else
          out << AdminDataValue.new(
            likert_score: score,
            academic_year:,
            school:,
            admin_data_item:
          )
        end
      end
      out
    end

    private_class_method :valid_likert_score
    private_class_method :likert_score
    private_class_method :ay
    private_class_method :dese_id
    private_class_method :admin_data_item
    private_class_method :create_admin_data_value
  end
end
