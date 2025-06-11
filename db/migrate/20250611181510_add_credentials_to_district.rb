class AddCredentialsToDistrict < ActiveRecord::Migration[8.0]
  def change
    add_column :districts, :username, :string, null: true, default: nil
    add_column :districts, :password, :string, null: true, default: nil
    add_column :districts, :login_required, :boolean, null: false, default: true
  end
end
