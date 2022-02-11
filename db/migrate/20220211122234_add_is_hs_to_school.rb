class AddIsHsToSchool < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :is_hs, :boolean, default: false
  end
end
