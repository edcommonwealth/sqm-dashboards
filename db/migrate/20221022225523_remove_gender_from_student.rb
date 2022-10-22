class RemoveGenderFromStudent < ActiveRecord::Migration[7.0]
  def change
    remove_column :students, :gender_id
  end
end
