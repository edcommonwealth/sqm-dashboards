class AddTwilioSidToAttempt < ActiveRecord::Migration[5.0]
  def change
    add_column :attempts, :twilio_sid, :string
    add_index :attempts, :twilio_sid
  end
end
