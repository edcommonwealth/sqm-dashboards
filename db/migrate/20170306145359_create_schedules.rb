class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.references :school, foreign_key: true
      t.string :name
      t.text :description
      t.integer :frequency_hours, default: 24
      t.date :start_date
      t.date :end_date
      t.boolean :active, default: true
      t.boolean :random, default: false
      t.integer :recipient_list_id
      t.integer :question_list_id

      t.timestamps
    end
  end
end
