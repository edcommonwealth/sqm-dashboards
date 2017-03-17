class AddCountersToRecipient < ActiveRecord::Migration[5.0]
  def change
    add_column :recipients, :attempts_count, :integer, default: 0
    add_column :recipients, :responses_count, :integer, default: 0
  end
end
