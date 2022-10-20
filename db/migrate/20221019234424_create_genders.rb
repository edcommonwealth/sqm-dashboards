class CreateGenders < ActiveRecord::Migration[7.0]
  def change
    create_table :genders do |t|
      t.integer :qualtrics_code
      t.string :designation

      t.timestamps
    end
  end
end
