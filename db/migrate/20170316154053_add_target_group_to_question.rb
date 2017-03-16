class AddTargetGroupToQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :target_group, :integer, default: 0
  end
end
