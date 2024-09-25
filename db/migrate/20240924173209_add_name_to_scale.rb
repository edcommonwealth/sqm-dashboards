class AddNameToScale < ActiveRecord::Migration[7.1]
  def change
    add_column :scales, :name, :string
    add_column :scales, :description, :string
  end
end
