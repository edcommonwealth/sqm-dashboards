class AddBenefitToParents < ActiveRecord::Migration[8.0]
  def change
    remove_reference :parents, :benefits, foreign_key: true
    add_reference :parents, :benefit, foreign_key: true
  end
end
