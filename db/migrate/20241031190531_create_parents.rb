class CreateParents < ActiveRecord::Migration[7.1]
  def change
    create_table :parents do |t|
      t.string :response_id
      t.integer :number_of_children

      t.timestamps
    end
  end
end
