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

ActiveRecord::Schema[7.0].define(version: 2023_06_22_224103) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "academic_years", id: :serial, force: :cascade do |t|
    t.string "range", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["range"], name: "index_academic_years_on_range", unique: true
  end

  create_table "admin_data_items", force: :cascade do |t|
    t.string "admin_data_item_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "watch_low_benchmark"
    t.float "growth_low_benchmark"
    t.float "approval_low_benchmark"
    t.float "ideal_low_benchmark"
    t.boolean "hs_only_item", default: false
    t.bigint "scale_id", null: false
    t.index ["admin_data_item_id"], name: "index_admin_data_items_on_admin_data_item_id", unique: true
    t.index ["scale_id"], name: "index_admin_data_items_on_scale_id"
  end

  create_table "admin_data_values", force: :cascade do |t|
    t.float "likert_score"
    t.bigint "school_id", null: false
    t.bigint "admin_data_item_id", null: false
    t.bigint "academic_year_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_admin_data_values_on_academic_year_id"
    t.index ["admin_data_item_id"], name: "index_admin_data_values_on_admin_data_item_id"
    t.index ["school_id"], name: "index_admin_data_values_on_school_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slug"
    t.integer "sort_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_id", null: false
    t.string "short_description"
    t.integer "subcategories_count"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "qualtrics_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genders", force: :cascade do |t|
    t.integer "qualtrics_code"
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_attempts", id: :serial, force: :cascade do |t|
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

  create_table "legacy_categories", id: :serial, force: :cascade do |t|
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

  create_table "legacy_districts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.integer "qualtrics_code"
    t.index ["slug"], name: "index_legacy_districts_on_slug", unique: true
  end

  create_table "legacy_question_lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "question_ids"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "legacy_questions", id: :serial, force: :cascade do |t|
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

  create_table "legacy_recipient_lists", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.string "name"
    t.text "description"
    t.text "recipient_ids"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["school_id"], name: "index_legacy_recipient_lists_on_school_id"
  end

  create_table "legacy_recipient_schedules", id: :serial, force: :cascade do |t|
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

  create_table "legacy_recipients", id: :serial, force: :cascade do |t|
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

  create_table "legacy_schedules", id: :serial, force: :cascade do |t|
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

  create_table "legacy_school_categories", id: :serial, force: :cascade do |t|
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

  create_table "legacy_school_questions", id: :serial, force: :cascade do |t|
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

  create_table "legacy_schools", id: :serial, force: :cascade do |t|
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

  create_table "legacy_students", id: :serial, force: :cascade do |t|
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

  create_table "legacy_user_schools", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "school_id"
    t.integer "district_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "legacy_users", id: :serial, force: :cascade do |t|
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

  create_table "measures", id: :serial, force: :cascade do |t|
    t.string "measure_id", null: false
    t.string "name"
    t.integer "subcategory_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "scales_count"
    t.index ["measure_id"], name: "index_measures_on_measure_id"
    t.index ["subcategory_id"], name: "index_measures_on_subcategory_id"
  end

  create_table "race_scores", force: :cascade do |t|
    t.bigint "measure_id", null: false
    t.bigint "school_id", null: false
    t.bigint "academic_year_id", null: false
    t.bigint "race_id", null: false
    t.float "average"
    t.boolean "meets_student_threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_race_scores_on_academic_year_id"
    t.index ["measure_id"], name: "index_race_scores_on_measure_id"
    t.index ["race_id"], name: "index_race_scores_on_race_id"
    t.index ["school_id"], name: "index_race_scores_on_school_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "designation"
    t.integer "qualtrics_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["designation"], name: "index_races_on_designation", unique: true
    t.index ["qualtrics_code"], name: "index_races_on_qualtrics_code", unique: true
    t.index ["slug"], name: "index_races_on_slug", unique: true
  end

  create_table "respondents", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "academic_year_id", null: false
    t.float "total_students"
    t.float "total_teachers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pk"
    t.integer "k"
    t.integer "one"
    t.integer "two"
    t.integer "three"
    t.integer "four"
    t.integer "five"
    t.integer "six"
    t.integer "seven"
    t.integer "eight"
    t.integer "nine"
    t.integer "ten"
    t.integer "eleven"
    t.integer "twelve"
    t.index ["academic_year_id"], name: "index_respondents_on_academic_year_id"
    t.index ["school_id", "academic_year_id"], name: "index_respondents_on_school_id_and_academic_year_id", unique: true
  end

  create_table "response_rates", force: :cascade do |t|
    t.bigint "subcategory_id", null: false
    t.bigint "school_id", null: false
    t.bigint "academic_year_id", null: false
    t.float "student_response_rate"
    t.float "teacher_response_rate"
    t.boolean "meets_student_threshold"
    t.boolean "meets_teacher_threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_response_rates_on_academic_year_id"
    t.index ["school_id", "subcategory_id"], name: "index_response_rates_on_school_id_and_subcategory_id"
    t.index ["subcategory_id"], name: "index_response_rates_on_subcategory_id"
  end

  create_table "scales", force: :cascade do |t|
    t.string "scale_id", null: false
    t.bigint "measure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "survey_items_count"
    t.index ["measure_id"], name: "index_scales_on_measure_id"
    t.index ["scale_id"], name: "index_scales_on_scale_id", unique: true
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.integer "district_id"
    t.text "description"
    t.string "slug"
    t.integer "qualtrics_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dese_id", null: false
    t.boolean "is_hs", default: false
    t.index ["dese_id"], name: "index_schools_on_dese_id", unique: true
  end

  create_table "scores", force: :cascade do |t|
    t.float "average"
    t.boolean "meets_teacher_threshold"
    t.boolean "meets_student_threshold"
    t.boolean "meets_admin_data_threshold"
    t.integer "group"
    t.bigint "measure_id", null: false
    t.bigint "school_id", null: false
    t.bigint "academic_year_id", null: false
    t.integer "grade"
    t.bigint "race_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_scores_on_academic_year_id"
    t.index ["measure_id"], name: "index_scores_on_measure_id"
    t.index ["race_id"], name: "index_scores_on_race_id"
    t.index ["school_id"], name: "index_scores_on_school_id"
  end

  create_table "student_races", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "race_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_student_races_on_race_id"
    t.index ["student_id", "race_id"], name: "index_student_races_on_student_id_and_race_id"
    t.index ["student_id"], name: "index_student_races_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "lasid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "response_id"
    t.index ["lasid"], name: "index_students_on_lasid"
  end

  create_table "subcategories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "category_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subcategory_id", null: false
    t.integer "measures_count"
  end

  create_table "survey_item_responses", id: :serial, force: :cascade do |t|
    t.integer "likert_score"
    t.integer "school_id", null: false
    t.integer "survey_item_id", null: false
    t.string "response_id", null: false
    t.integer "academic_year_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "student_id"
    t.integer "grade"
    t.bigint "gender_id"
    t.datetime "recorded_date"
    t.index ["academic_year_id"], name: "index_survey_item_responses_on_academic_year_id"
    t.index ["gender_id"], name: "index_survey_item_responses_on_gender_id"
    t.index ["response_id"], name: "index_survey_item_responses_on_response_id"
    t.index ["school_id", "academic_year_id", "survey_item_id"], name: "by_school_year_and_survey_item"
    t.index ["school_id", "academic_year_id"], name: "index_survey_item_responses_on_school_id_and_academic_year_id"
    t.index ["school_id", "survey_item_id", "academic_year_id", "grade"], name: "index_survey_responses_on_grade"
    t.index ["student_id"], name: "index_survey_item_responses_on_student_id"
    t.index ["survey_item_id"], name: "index_survey_item_responses_on_survey_item_id"
  end

  create_table "survey_items", id: :serial, force: :cascade do |t|
    t.string "survey_item_id", null: false
    t.string "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "watch_low_benchmark"
    t.float "growth_low_benchmark"
    t.float "approval_low_benchmark"
    t.float "ideal_low_benchmark"
    t.bigint "scale_id", null: false
    t.boolean "on_short_form", default: false
    t.integer "survey_item_responses_count"
    t.index ["scale_id"], name: "index_survey_items_on_scale_id"
    t.index ["survey_item_id"], name: "index_survey_items_on_survey_item_id"
  end

  add_foreign_key "admin_data_items", "scales"
  add_foreign_key "admin_data_values", "academic_years"
  add_foreign_key "admin_data_values", "admin_data_items"
  add_foreign_key "admin_data_values", "schools"
  add_foreign_key "legacy_recipient_lists", "legacy_schools", column: "school_id"
  add_foreign_key "legacy_schedules", "legacy_schools", column: "school_id"
  add_foreign_key "legacy_school_categories", "legacy_categories", column: "category_id"
  add_foreign_key "legacy_school_categories", "legacy_schools", column: "school_id"
  add_foreign_key "measures", "subcategories"
  add_foreign_key "race_scores", "academic_years"
  add_foreign_key "race_scores", "measures"
  add_foreign_key "race_scores", "races"
  add_foreign_key "race_scores", "schools"
  add_foreign_key "respondents", "academic_years"
  add_foreign_key "respondents", "schools"
  add_foreign_key "response_rates", "academic_years"
  add_foreign_key "response_rates", "schools"
  add_foreign_key "response_rates", "subcategories"
  add_foreign_key "scales", "measures"
  add_foreign_key "schools", "districts"
  add_foreign_key "scores", "academic_years"
  add_foreign_key "scores", "measures"
  add_foreign_key "scores", "races"
  add_foreign_key "scores", "schools"
  add_foreign_key "student_races", "races"
  add_foreign_key "student_races", "students"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "survey_item_responses", "academic_years"
  add_foreign_key "survey_item_responses", "genders"
  add_foreign_key "survey_item_responses", "schools"
  add_foreign_key "survey_item_responses", "students"
  add_foreign_key "survey_item_responses", "survey_items"
  add_foreign_key "survey_items", "scales"
end
