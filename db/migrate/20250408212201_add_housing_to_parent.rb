class AddHousingToParent < ActiveRecord::Migration[8.0]
  def change
    add_reference :parents, :housing, foreign_key: true
  end
end
