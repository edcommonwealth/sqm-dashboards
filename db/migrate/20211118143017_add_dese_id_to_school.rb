class AddDeseIdToSchool < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :dese_id, :integer, default: -1, null: false

    change_column_default :schools, :dese_id, from: -1, to: nil
  end
end
