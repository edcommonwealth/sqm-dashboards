class CreateRecipients < ActiveRecord::Migration[5.0]
  def change
    create_table :recipients do |t|
      t.string :name
      t.string :phone
      t.date :birth_date
      t.string :gender
      t.string :race
      t.string :ethnicity
      t.integer :home_language_id
      t.string :income
      t.boolean :opted_out, default: false
      t.integer :school_id

      t.timestamps
    end
  end
end
