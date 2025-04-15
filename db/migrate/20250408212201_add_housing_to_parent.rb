class AddHousingToParent < ActiveRecord::Migration[8.0]
  def change
    add_reference :parents, :housing, foreign_key: true
    Parent.update_all(housing_id: Housing.find_by(designation: 'Unknown').id)
    change_column_null :parents, :housing_id, false
  end
end
