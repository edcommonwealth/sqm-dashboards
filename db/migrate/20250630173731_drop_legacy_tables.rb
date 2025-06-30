class DropLegacyTables < ActiveRecord::Migration[8.0]
  def change
    # drop_table :legacy_recipient_schedules do |t|
    #   t.integer "recipient_id"
    #   t.integer "schedule_id"
    #   t.text "upcoming_question_ids"
    #   t.text "attempted_question_ids"
    #   t.datetime "last_attempt_at", precision: nil
    #   t.datetime "created_at", precision: nil, null: false
    #   t.datetime "updated_at", precision: nil, null: false
    #   t.datetime "next_attempt_at", precision: nil
    #   t.string "queued_question_ids"
    # end
    # drop_table :legacy_students do |t|
    #   t.string "name"
    #   t.string "teacher"
    #   t.date "birthdate"
    #   t.string "gender"
    #   t.string "age"
    #   t.string "ethnicity"
    #   t.integer "recipient_id"
    #   t.datetime "created_at", precision: nil, null: false
    #   t.datetime "updated_at", precision: nil, null: false
    # end
    drop_table :legacy_recipient_lists do |t|
      t.integer "school_id"
      t.string "name"
      t.text "description"
      t.text "recipient_ids"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["school_id"], name: "index_legacy_recipient_lists_on_school_id"
    end
    drop_table :legacy_question_lists do |t|
      t.string "name"
      t.text "description"
      t.text "question_ids"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
    drop_table :legacy_attempts do |t|
      t.integer "recipient_id"
      t.integer "schedule_id"
      t.integer "recipient_schedule_id"
      t.datetime "sent_at", precision: nil
      t.datetime "responded_at", precision: nil
      t.integer "question_id"
      t.integer "translation_id"
      t.integer "answer_index"
      t.integer "open_response_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.text "twilio_details"
      t.string "twilio_sid"
      t.integer "student_id"
      t.index ["twilio_sid"], name: "index_legacy_attempts_on_twilio_sid"
    end
    drop_table :legacy_recipients do |t|
      t.string "name"
      t.string "phone"
      t.date "birth_date"
      t.string "gender"
      t.string "race"
      t.string "ethnicity"
      t.integer "home_language_id"
      t.string "income"
      t.boolean "opted_out", default: false
      t.integer "school_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "email"
      t.string "slug"
      t.integer "attempts_count", default: 0
      t.integer "responses_count", default: 0
      t.string "teacher"
      t.index ["phone"], name: "index_legacy_recipients_on_phone"
      t.index ["slug"], name: "index_legacy_recipients_on_slug", unique: true
    end
    drop_table :legacy_schedules do |t|
      t.integer "school_id"
      t.string "name"
      t.text "description"
      t.integer "frequency_hours", default: 24
      t.date "start_date"
      t.date "end_date"
      t.boolean "active", default: true
      t.boolean "random", default: false
      t.integer "recipient_list_id"
      t.integer "question_list_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "time", default: 960
      t.index ["school_id"], name: "index_legacy_schedules_on_school_id"
    end
    drop_table :legacy_questions do |t|
      t.string "text"
      t.string "option1"
      t.string "option2"
      t.string "option3"
      t.string "option4"
      t.string "option5"
      t.integer "category_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "target_group", default: 0
      t.boolean "for_recipient_students", default: false
      t.boolean "reverse", default: false
      t.string "external_id"
    end
    drop_table :legacy_school_categories do |t|
      t.integer "school_id"
      t.integer "category_id"
      t.integer "attempt_count", default: 0
      t.integer "response_count", default: 0
      t.integer "answer_index_total", default: 0
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.float "nonlikert"
      t.float "zscore"
      t.string "year"
      t.integer "valid_child_count"
      t.integer "response_rate"
      t.index ["category_id"], name: "index_legacy_school_categories_on_category_id"
      t.index ["school_id"], name: "index_legacy_school_categories_on_school_id"
    end
    drop_table :legacy_school_questions do |t|
      t.integer "school_id"
      t.integer "question_id"
      t.integer "school_category_id"
      t.integer "attempt_count"
      t.integer "response_count"
      t.float "response_rate"
      t.string "year"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "response_total"
    end
    drop_table :legacy_schools do |t|
      t.string "name"
      t.integer "district_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.text "description"
      t.string "slug"
      t.integer "student_count"
      t.integer "teacher_count"
      t.integer "qualtrics_code"
      t.index ["slug"], name: "index_legacy_schools_on_slug", unique: true
    end
    drop_table :legacy_districts do |t|
      t.string "name"
      t.integer "state_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "slug"
      t.integer "qualtrics_code"
      t.index ["slug"], name: "index_legacy_districts_on_slug", unique: true
    end
    drop_table :legacy_categories do |t|
      t.string "name"
      t.string "blurb"
      t.text "description"
      t.string "external_id"
      t.integer "parent_category_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "slug"
      t.float "benchmark"
      t.string "benchmark_description"
      t.string "zones"
      t.index ["slug"], name: "index_legacy_categories_on_slug", unique: true
    end
    drop_table :legacy_user_schools do |t|
      t.integer "user_id"
      t.integer "school_id"
      t.integer "district_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
    drop_table :legacy_users do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at", precision: nil
      t.datetime "remember_created_at", precision: nil
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at", precision: nil
      t.datetime "last_sign_in_at", precision: nil
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["email"], name: "index_legacy_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_legacy_users_on_reset_password_token", unique: true
    end
  end
end
