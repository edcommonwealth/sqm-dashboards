class AddEducationToParent < ActiveRecord::Migration[8.0]
  def change
    add_reference :parents, :education, foreign_key: true
  end
end
