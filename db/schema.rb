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

ActiveRecord::Schema[8.0].define(version: 2025_07_04_001027) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "academic_years", id: :serial, force: :cascade do |t|
    t.string "range", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["range"], name: "index_academic_years_on_range", unique: true
    t.index ["slug"], name: "index_academic_years_on_slug", unique: true
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

  create_table "benefits", force: :cascade do |t|
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "username"
    t.string "password"
    t.boolean "login_required", default: true, null: false
    t.index ["name"], name: "index_districts_on_name", unique: true
    t.index ["qualtrics_code"], name: "index_districts_on_qualtrics_code", unique: true
    t.index ["slug"], name: "index_districts_on_slug", unique: true
  end

  create_table "educations", force: :cascade do |t|
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ells", force: :cascade do |t|
    t.string "designation"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["designation"], name: "index_ells_on_designation", unique: true
  end

  create_table "employments", force: :cascade do |t|
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genders", force: :cascade do |t|
    t.integer "qualtrics_code"
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_genders_on_slug", unique: true
  end

  create_table "housings", force: :cascade do |t|
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incomes", force: :cascade do |t|
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_incomes_on_slug", unique: true
  end

  create_table "languages", force: :cascade do |t|
    t.string "designation"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["designation"], name: "index_languages_on_designation"
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

  create_table "parent_employments", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "employment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employment_id"], name: "index_parent_employments_on_employment_id"
    t.index ["parent_id"], name: "index_parent_employments_on_parent_id"
  end

  create_table "parent_genders", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "gender_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gender_id"], name: "index_parent_genders_on_gender_id"
    t.index ["parent_id"], name: "index_parent_genders_on_parent_id"
  end

  create_table "parent_languages", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_parent_languages_on_language_id"
    t.index ["parent_id", "language_id"], name: "index_parent_languages_on_parent_id_and_language_id"
    t.index ["parent_id"], name: "index_parent_languages_on_parent_id"
  end

  create_table "parent_races", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "race_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_parent_races_on_parent_id"
    t.index ["race_id"], name: "index_parent_races_on_race_id"
  end

  create_table "parents", force: :cascade do |t|
    t.string "response_id"
    t.integer "number_of_children"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "housing_id"
    t.bigint "education_id"
    t.integer "socio_economic_status"
    t.bigint "benefit_id"
    t.index ["benefit_id"], name: "index_parents_on_benefit_id"
    t.index ["education_id"], name: "index_parents_on_education_id"
    t.index ["housing_id"], name: "index_parents_on_housing_id"
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
    t.integer "total_esp"
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
    t.string "name"
    t.string "description"
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

  create_table "speds", force: :cascade do |t|
    t.string "designation"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["designation"], name: "index_speds_on_designation"
  end

  create_table "student_races", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "race_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_student_races_on_race_id"
    t.index ["student_id", "race_id"], name: "index_student_races_on_student_id_and_race_id"
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
    t.bigint "income_id"
    t.datetime "recorded_date"
    t.bigint "ell_id"
    t.bigint "sped_id"
    t.bigint "parent_id"
    t.index ["academic_year_id"], name: "index_survey_item_responses_on_academic_year_id"
    t.index ["ell_id"], name: "index_survey_item_responses_on_ell_id"
    t.index ["gender_id"], name: "index_survey_item_responses_on_gender_id"
    t.index ["income_id"], name: "index_survey_item_responses_on_income_id"
    t.index ["parent_id"], name: "index_survey_item_responses_on_parent_id"
    t.index ["response_id"], name: "index_survey_item_responses_on_response_id"
    t.index ["school_id", "academic_year_id", "survey_item_id"], name: "by_school_year_and_survey_item"
    t.index ["school_id", "survey_item_id", "academic_year_id", "grade"], name: "index_survey_responses_on_grade"
    t.index ["sped_id"], name: "index_survey_item_responses_on_sped_id"
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
    t.index ["survey_item_id"], name: "index_survey_items_on_survey_item_id", unique: true
  end

  add_foreign_key "admin_data_items", "scales"
  add_foreign_key "admin_data_values", "academic_years"
  add_foreign_key "admin_data_values", "admin_data_items"
  add_foreign_key "admin_data_values", "schools"
  add_foreign_key "measures", "subcategories"
  add_foreign_key "parent_employments", "employments"
  add_foreign_key "parent_employments", "parents"
  add_foreign_key "parent_genders", "genders"
  add_foreign_key "parent_genders", "parents"
  add_foreign_key "parent_languages", "languages"
  add_foreign_key "parent_languages", "parents"
  add_foreign_key "parent_races", "parents"
  add_foreign_key "parent_races", "races"
  add_foreign_key "parents", "benefits"
  add_foreign_key "parents", "educations"
  add_foreign_key "parents", "housings"
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
  add_foreign_key "survey_item_responses", "ells"
  add_foreign_key "survey_item_responses", "genders"
  add_foreign_key "survey_item_responses", "incomes"
  add_foreign_key "survey_item_responses", "parents"
  add_foreign_key "survey_item_responses", "schools"
  add_foreign_key "survey_item_responses", "speds"
  add_foreign_key "survey_item_responses", "students"
  add_foreign_key "survey_item_responses", "survey_items"
  add_foreign_key "survey_items", "scales"
end
