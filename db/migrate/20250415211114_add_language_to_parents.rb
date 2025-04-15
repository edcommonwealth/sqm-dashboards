class AddLanguageToParents < ActiveRecord::Migration[8.0]
  def change
    add_reference :parents, :language, foreign_key: true
  end
end
