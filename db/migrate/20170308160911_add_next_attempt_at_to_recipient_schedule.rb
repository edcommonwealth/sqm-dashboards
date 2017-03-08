class AddNextAttemptAtToRecipientSchedule < ActiveRecord::Migration[5.0]
  def change
    add_column :recipient_schedules, :next_attempt_at, :timestamp
  end
end
