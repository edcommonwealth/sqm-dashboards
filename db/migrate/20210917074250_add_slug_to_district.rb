class AddSlugToDistrict < ActiveRecord::Migration[5.0]
  def up
    add_column :districts, :slug, :string
    add_index :districts, :slug, unique: true
    District.all.each { |district| district.update(slug: district.slug ||= district.name.parameterize) }
  end

  def down
    remove_column :districts, :slug
  end
end
