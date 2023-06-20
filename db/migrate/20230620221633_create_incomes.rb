class CreateIncomes < ActiveRecord::Migration[7.0]
  def change
    create_table :incomes do |t|
      t.string :designation

      t.timestamps
    end
  end
end
