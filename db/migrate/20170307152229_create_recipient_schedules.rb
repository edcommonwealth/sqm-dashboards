class CreateRecipientSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :recipient_schedules do |t|
      t.integer :recipient_id
      t.integer :schedule_id
      t.text :upcoming_question_ids
      t.text :attempted_question_ids
      t.timestamp :last_attempt_at

      t.timestamps
    end
  end
end
