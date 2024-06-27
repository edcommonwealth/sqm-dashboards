class AddSlugToGender < ActiveRecord::Migration[7.1]
  def change
    add_column :genders, :slug, :string
    add_index :genders, :slug, unique: true
  end
end
