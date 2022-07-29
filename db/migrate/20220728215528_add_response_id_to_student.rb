class AddResponseIdToStudent < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :response_id, :string
  end
end
