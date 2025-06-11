class AddNameSlugAndQualtricsCodeIndexesToDistrict < ActiveRecord::Migration[8.0]
  def change
    add_index :districts, :name, unique: true
    add_index :districts, :slug, unique: true
    add_index :districts, :qualtrics_code, unique: true
  end
end
