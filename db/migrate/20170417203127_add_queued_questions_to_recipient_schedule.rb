class AddQueuedQuestionsToRecipientSchedule < ActiveRecord::Migration[5.0]
  def change
    add_column :recipient_schedules, :queued_question_ids, :string
    add_column :recipients, :teacher, :string
  end
end
