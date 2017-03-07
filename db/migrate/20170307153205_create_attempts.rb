class CreateAttempts < ActiveRecord::Migration[5.0]
  def change
    create_table :attempts do |t|
      t.integer :recipient_id
      t.integer :schedule_id
      t.integer :recipient_schedule_id
      t.timestamp :sent_at
      t.timestamp :responded_at
      t.integer :question_id
      t.integer :translation_id
      t.integer :answer_index
      t.integer :open_response_id

      t.timestamps
    end
  end
end
