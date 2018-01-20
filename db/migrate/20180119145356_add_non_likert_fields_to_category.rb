class AddNonLikertFieldsToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :benchmark, :float
    add_column :categories, :benchmark_description, :string

    add_column :school_categories, :nonlikert, :float
  end
end
