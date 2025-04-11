class AddDesignationIndexToLanguage < ActiveRecord::Migration[8.0]
  def change
    add_index :languages, %i[designation]
  end
end
