class CreateEmployments < ActiveRecord::Migration[8.0]
  def change
    create_table :employments do |t|
      t.string :designation

      t.timestamps
    end
  end
end
