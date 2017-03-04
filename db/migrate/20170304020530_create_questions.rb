class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :text
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4
      t.string :option5
      t.integer :category_id

      t.timestamps
    end
  end
end
