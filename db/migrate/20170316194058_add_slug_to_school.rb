class AddSlugToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :slug, :string
    add_index :schools, :slug, unique: true
  end
end
