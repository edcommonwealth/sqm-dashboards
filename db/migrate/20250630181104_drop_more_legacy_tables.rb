class DropMoreLegacyTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :legacy_recipient_schedules do |t|
      t.integer "recipient_id"
      t.integer "schedule_id"
      t.text "upcoming_question_ids"
      t.text "attempted_question_ids"
      t.datetime "last_attempt_at", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.datetime "next_attempt_at", precision: nil
      t.string "queued_question_ids"
    end
    drop_table :legacy_students do |t|
      t.string "name"
      t.string "teacher"
      t.date "birthdate"
      t.string "gender"
      t.string "age"
      t.string "ethnicity"
      t.integer "recipient_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
  end
end
