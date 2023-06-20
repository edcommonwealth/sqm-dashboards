class AddSlugToIncome < ActiveRecord::Migration[7.0]
  def change
    add_column :incomes, :slug, :string
    add_index :incomes, :slug, unique: true
  end
end
