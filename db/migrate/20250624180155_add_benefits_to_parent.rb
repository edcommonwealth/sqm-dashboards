class AddBenefitsToParent < ActiveRecord::Migration[8.0]
  def change
    add_reference :parents, :benefits, foreign_key: true
  end
end
