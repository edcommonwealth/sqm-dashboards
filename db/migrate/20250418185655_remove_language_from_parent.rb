class RemoveLanguageFromParent < ActiveRecord::Migration[8.0]
  def change
    remove_column :parents, :language_id
  end
end
