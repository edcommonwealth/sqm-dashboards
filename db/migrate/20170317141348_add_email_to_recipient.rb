class AddEmailToRecipient < ActiveRecord::Migration[5.0]
  def change
    add_column :recipients, :email, :string
    add_column :recipients, :slug, :string
    add_index :recipients, :slug, unique: true
  end
end
