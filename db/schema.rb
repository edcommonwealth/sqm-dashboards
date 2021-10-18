# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_14_202830) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academic_years", id: :serial, force: :cascade do |t|
    t.string "range", null: false
    t.index ["range"], name: "index_academic_years_on_range", unique: true
  end

  create_table "attempts", id: :serial, force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "schedule_id"
    t.integer "recipient_schedule_id"
    t.datetime "sent_at"
    t.datetime "responded_at"
    t.integer "question_id"
    t.integer "translation_id"
    t.integer "answer_index"
    t.integer "open_response_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "twilio_details"
    t.string "twilio_sid"
    t.integer "student_id"
    t.index ["twilio_sid"], name: "index_attempts_on_twilio_sid"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "blurb"
    t.text "description"
    t.string "external_id"
    t.integer "parent_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.float "benchmark"
    t.string "benchmark_description"
    t.string "zones"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "districts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "qualtrics_code"
    t.index ["slug"], name: "index_districts_on_slug", unique: true
  end

  create_table "measures", id: :serial, force: :cascade do |t|
    t.string "measure_id", null: false
    t.string "name"
    t.float "watch_low_benchmark", null: false
    t.float "growth_low_benchmark", null: false
    t.float "approval_low_benchmark", null: false
    t.float "ideal_low_benchmark", null: false
    t.integer "subcategory_id", null: false
    t.text "description"
    t.index ["measure_id"], name: "index_measures_on_measure_id"
    t.index ["subcategory_id"], name: "index_measures_on_subcategory_id"
  end

  create_table "question_lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "question_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "text"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.string "option4"
    t.string "option5"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target_group", default: 0
    t.boolean "for_recipient_students", default: false
    t.boolean "reverse", default: false
    t.string "external_id"
  end

  create_table "recipient_lists", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.string "name"
    t.text "description"
    t.text "recipient_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_recipient_lists_on_school_id"
  end

  create_table "recipient_schedules", id: :serial, force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "schedule_id"
    t.text "upcoming_question_ids"
    t.text "attempted_question_ids"
    t.datetime "last_attempt_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "next_attempt_at"
    t.string "queued_question_ids"
  end

  create_table "recipients", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "slug"
    t.integer "attempts_count", default: 0
    t.integer "responses_count", default: 0
    t.string "teacher"
    t.index ["phone"], name: "index_recipients_on_phone"
    t.index ["slug"], name: "index_recipients_on_slug", unique: true
  end

  create_table "schedules", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time", default: 960
    t.index ["school_id"], name: "index_schedules_on_school_id"
  end

  create_table "school_categories", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.integer "category_id"
    t.integer "attempt_count", default: 0
    t.integer "response_count", default: 0
    t.integer "answer_index_total", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "nonlikert"
    t.float "zscore"
    t.string "year"
    t.integer "valid_child_count"
    t.integer "response_rate"
    t.index ["category_id"], name: "index_school_categories_on_category_id"
    t.index ["school_id"], name: "index_school_categories_on_school_id"
  end

  create_table "school_questions", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.integer "question_id"
    t.integer "school_category_id"
    t.integer "attempt_count"
    t.integer "response_count"
    t.float "response_rate"
    t.string "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "response_total"
  end

  create_table "schools", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "district_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "slug"
    t.integer "student_count"
    t.integer "teacher_count"
    t.integer "qualtrics_code"
    t.index ["slug"], name: "index_schools_on_slug", unique: true
  end

  create_table "sqm_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slug"
    t.integer "sort_index"
    t.index ["slug"], name: "index_sqm_categories_on_slug", unique: true
  end

  create_table "students", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "teacher"
    t.date "birthdate"
    t.string "gender"
    t.string "age"
    t.string "ethnicity"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subcategories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "sqm_category_id"
    t.text "description"
  end

  create_table "survey_item_responses", id: :serial, force: :cascade do |t|
    t.integer "likert_score"
    t.integer "school_id", null: false
    t.integer "survey_item_id", null: false
    t.string "response_id", null: false
    t.integer "academic_year_id", null: false
    t.index ["academic_year_id"], name: "index_survey_item_responses_on_academic_year_id"
    t.index ["response_id"], name: "index_survey_item_responses_on_response_id"
    t.index ["school_id"], name: "index_survey_item_responses_on_school_id"
    t.index ["survey_item_id"], name: "index_survey_item_responses_on_survey_item_id"
  end

  create_table "survey_items", id: :serial, force: :cascade do |t|
    t.integer "measure_id", null: false
    t.string "survey_item_id", null: false
    t.string "prompt"
    t.index ["measure_id"], name: "index_survey_items_on_measure_id"
    t.index ["survey_item_id"], name: "index_survey_items_on_survey_item_id"
  end

  create_table "user_schools", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "school_id"
    t.integer "district_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "measures", "subcategories"
  add_foreign_key "recipient_lists", "schools"
  add_foreign_key "schedules", "schools"
  add_foreign_key "school_categories", "categories"
  add_foreign_key "school_categories", "schools"
  add_foreign_key "subcategories", "sqm_categories"
  add_foreign_key "survey_item_responses", "academic_years"
  add_foreign_key "survey_item_responses", "schools"
  add_foreign_key "survey_item_responses", "survey_items"
  add_foreign_key "survey_items", "measures"
end
