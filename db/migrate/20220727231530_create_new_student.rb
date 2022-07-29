class CreateNewStudent < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :lasid

      t.timestamps
    end

    add_index :students, :lasid
  end
end
