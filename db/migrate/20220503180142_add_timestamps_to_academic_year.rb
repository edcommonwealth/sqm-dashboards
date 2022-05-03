class AddTimestampsToAcademicYear < ActiveRecord::Migration[7.0]
  def change
    now = Time.zone.now
    change_table :academic_years do |t|
      t.timestamps default: now
    end
    change_column_default :academic_years, :created_at, from: now, to: nil
    change_column_default :academic_years, :updated_at, from: now, to: nil
  end
end
