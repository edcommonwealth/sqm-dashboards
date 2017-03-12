class AddDescriptionToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :description, :text
    add_index :recipients, :phone
  end
end
