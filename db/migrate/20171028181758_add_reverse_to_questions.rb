class AddReverseToQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :reverse, :boolean, default: false
  end
end
