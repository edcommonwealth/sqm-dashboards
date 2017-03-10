class AddTwilioDetailsToAttempts < ActiveRecord::Migration[5.0]
  def change
    add_column :attempts, :twilio_details, :text
  end
end
