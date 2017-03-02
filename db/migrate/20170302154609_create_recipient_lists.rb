class CreateRecipientLists < ActiveRecord::Migration[5.0]
  def change
    create_table :recipient_lists do |t|
      t.references :school, foreign_key: true
      t.string :name
      t.text :description
      t.text :recipient_ids

      t.timestamps
    end
  end
end
