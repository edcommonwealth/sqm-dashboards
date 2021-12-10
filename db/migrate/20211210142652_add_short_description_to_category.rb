class AddShortDescriptionToCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :short_description, :string
  end
end
