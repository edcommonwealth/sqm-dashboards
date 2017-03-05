class CreateQuestionLists < ActiveRecord::Migration[5.0]
  def change
    create_table :question_lists do |t|
      t.string :name
      t.text :description
      t.text :question_ids

      t.timestamps
    end
  end
end
