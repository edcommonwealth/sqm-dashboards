class AddZonesToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :zones, :string
  end
end


[76, 90], [77, 91], [71, 85], [73, 86], [73, 86]
Category.all.each { |category| category.update() }
