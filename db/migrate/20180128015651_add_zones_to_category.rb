class AddZonesToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :zones, :string
  end
end
