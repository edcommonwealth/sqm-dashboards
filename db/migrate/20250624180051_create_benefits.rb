class CreateBenefits < ActiveRecord::Migration[8.0]
  def change
    create_table :benefits do |t|
      t.string :designation

      t.timestamps
    end
  end
end
