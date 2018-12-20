class AddSchoolQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :school_questions do |t|
      t.integer :school_id
      t.integer :question_id
      t.integer :school_category_id
      t.integer :attempt_count
      t.integer :response_count
      t.float   :response_rate
      t.string  :year

      t.timestamps
    end

    add_column :school_categories, :valid_child_count, :integer
    add_column :school_categories, :response_rate, :integer
  end
end
